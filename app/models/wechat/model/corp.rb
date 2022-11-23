module Wechat
  module Model::Corp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string, index: true
      attribute :corp_type, :string
      attribute :subject_type, :string
      attribute :verified_end_at, :datetime
      attribute :square_logo_url, :string
      attribute :user_max, :integer
      attribute :full_name, :string
      attribute :wxqrcode, :string
      attribute :industry, :string
      attribute :sub_industry, :string
      attribute :location, :string
      attribute :auth_corp_info, :json
      attribute :auth_user_info, :json
      attribute :register_code_info, :json
      attribute :agent, :json
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :jsapi_ticket, :string
      attribute :jsapi_ticket_expires_at, :datetime
      attribute :agent_ticket, :string
      attribute :agent_ticket_expires_at, :datetime
      attribute :permanent_code, :string
      attribute :suite_id, :string
      attribute :host, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :debug, :boolean, default: false

      belongs_to :organ_domain, class_name: 'Org::OrganDomain', foreign_key: :host, primary_key: :identifier, optional: true
      has_one :organ, class_name: 'Org::Organ', through: :organ_domain

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true

      has_many :corp_tickets, ->(o) { where(suiteid: o.suite_id) }
      has_many :corp_users, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id
      has_many :contacts, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id
      has_many :externals, foreign_key: :corp_id, primary_key: :corp_id
    end

    def decrypt(msg)
      Wechat::Cipher.qy_decrypt(msg, encoding_aes_key)
    end

    def oauth_enable
      true
    end

    def secret
      permanent_code
    end

    def appid
      corp_id
    end

    def init_organ
      organ || build_organ
      organ.name_short = name
      organ.name = full_name
      organ.save
    end

    # todo 这个方法跟 work app 下的方法是类似的，后期合并
    def generate_corp_user(code)
      result = api.auth_user(code)
      logger.debug "\e[35m  auth_user: #{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(user_id: result['userid'])
      corp_user.organ_id = organ&.id

      if result['user_ticket'] && corp_user.temp?
        corp_user.user_ticket = result['user_ticket']
        corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
        detail = api.user_detail(result['user_ticket'])
        logger.debug "\e[35m  user_detail: #{detail}  \e[0m"

        if detail['errcode'] == 0
          corp_user.assign_attributes detail.slice('gender', 'qr_code')
          corp_user.identity = detail['mobile']
          corp_user.avatar_url = detail['avatar']
        end
      end

      corp_user.save
      corp_user
    end

    def assign_info(info)
      self.assign_attributes info.slice('access_token', 'permanent_code', 'auth_corp_info', 'auth_user_info')
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token']
      self.agent = info.fetch('auth_info', {}).fetch('agent', [])[0]

      corp_info = info.fetch('auth_corp_info', {})
      self.assign_attributes corp_info.slice('corp_type', 'subject_type')
      self.assign_attributes corp_info.transform_keys(&->(i){ i.delete_prefix('corp_') }).slice('name', 'square_logo_url', 'user_max', 'wxqrcode', 'full_name', 'industry', 'sub_industry', 'location')
      self.verified_end_at = Time.at(corp_info['verified_end_time']) if corp_info['verified_end_time'].is_a? Numeric
    end

    def auth_info
      info = suite.provider.api.auth_info(corp_id, permanent_code)
      assign_info(info)
      save
    end

    def sync_contacts
      items = api.list_contact_way.fetch('contact_way', [])
      items.each do |item|
        r = api.get_contact_way(item['config_id'])
        info = r['contact_way']
        info['user'].each do |user|
          contact = self.contacts.find_or_initialize_by(user_id: user, config_id: item['config_id'])
          contact.assign_attributes info.slice('qr_code', 'remark', 'skip_verify', 'state')
          contact.save
        end
      end
    end

    def js_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      js_hash = Wechat::Signature.signature(jsapi_ticket, url)
      js_hash.merge!(
        beta: true,
        appid: corp_id
      )

      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

    def js_login(**url_options)
      url_options.with_defaults! controller: 'wechat/corps', action: 'login', id: id, host: host
      {
        appid: appid,
        agentid: agentid,
        redirect_uri: ERB::Util.url_encode(Rails.application.routes.url_for(**url_options)),
        state: StateUtil.urlsafe_encode64(host: host, controller: 'me/home')
      }
    end

    def agentid
      agent['agentid']
    end

    def agent_config(url = '/')
      refresh_agent_ticket unless agent_ticket_valid?
      js_hash = Wechat::Signature.signature(agent_ticket, url)
      js_hash.merge!(
        corpid: corp_id,
        agentid: agentid
      )

      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

    def oauth2_url(scope: 'snsapi_privateinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/corps', action: 'login', id: id, host: host
      h = {
        appid: corp_id,
        redirect_uri: ERB::Util.url_encode(Rails.application.routes.url_for(**url_options)),
        response_type: 'code',
        scope: scope,
        state: state,
        agentid: agentid
      }

      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def refresh_access_token
      if suite.kind_develop?
        info = api.token
      else
        info = suite.api.corp_token(corp_id, permanent_code)
      end
      self.access_token = info['access_token']
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token'] && self.access_token_changed?
      self.save
      info
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def refresh_agent_ticket
      info = api.agent_ticket
      self.agent_ticket = info['ticket']
      self.agent_ticket_expires_at = Time.current + info['expires_in'].to_i if info['ticket'] && self.agent_ticket_changed?
      self.save
      info
    end

    def agent_ticket_valid?
      agent_ticket_expires_at.acts_like?(:time) && agent_ticket_expires_at > Time.current
    end

    def refresh_jsapi_ticket
      info = api.jsapi_ticket
      self.jsapi_ticket = info['ticket']
      self.jsapi_ticket_expires_at = Time.current + info['expires_in'].to_i if info['ticket'] && self.jsapi_ticket_changed?
      self.save
      info
    end

    def jsapi_ticket_valid?
      jsapi_ticket_expires_at.acts_like?(:time) && jsapi_ticket_expires_at > Time.current
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Work.new(self)
    end

  end
end
