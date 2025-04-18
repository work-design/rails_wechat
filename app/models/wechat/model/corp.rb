module Wechat
  module Model::Corp
    extend ActiveSupport::Concern
    include Inner::Token
    include Inner::JsToken
    include Inner::Agent

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :corpid, :string, index: true
      attribute :open_corpid, :string, index: true
      attribute :agentid, :string
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
      attribute :agent_ticket, :string
      attribute :agent_ticket_expires_at, :datetime
      attribute :permanent_code, :string
      attribute :suite_id, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :debug, :boolean, default: false

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      has_many :profiles, class_name: 'Profiled::Profile', primary_key: :corpid, foreign_key: :corpid

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true

      has_many :suite_receives, ->(o) { where(suiteid: o.suite_id) }, primary_key: :open_corpid, foreign_key: :auth_corp_id
      has_many :corp_users, ->(o) { where(suite_id: o.suite_id) }, primary_key: :corpid, foreign_key: :corpid
      has_many :contacts, ->(o) { where(suite_id: o.suite_id) }, primary_key: :corpid, foreign_key: :corpid
      has_many :supporters, primary_key: :corpid, foreign_key: :corpid

      before_validation :init_aes_key, if: -> { encoding_aes_key.blank? || token.blank? }
      before_validation :sync_agentid, if: -> { agent_changed? && agent.present? }
      before_create :init_organ
    end

    def init_aes_key
      self.token = token.presence || SecureRandom.alphanumeric(24)
      self.encoding_aes_key = encoding_aes_key.presence || SecureRandom.alphanumeric(43)
    end

    def sync_agentid
      self.agentid = agent['agentid']
    end

    def decrypt(encrypt_data)
      Wechat::Cipher.decrypt(encrypt_data, encoding_aes_key)
    end

    def receive_filter
      if corpid != open_corpid
        { corpid: corpid }
      else
        { auth_corp_id: open_corpid }
      end
    end

    def appid
      corpid
    end

    def init_organ
      organ || create_organ(name: name)
    end

    def assign_info(info)
      self.assign_attributes info.slice('access_token', 'permanent_code', 'auth_corp_info', 'auth_user_info')
      self.secret = info['permanent_code']
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token']
      self.agent = info.fetch('auth_info', {}).fetch('agent', [])[0]

      corp_info = info.fetch('auth_corp_info', {})
      self.assign_attributes corp_info.slice('corp_type', 'subject_type')
      self.assign_attributes corp_info.transform_keys(&->(i){ i.delete_prefix('corp_') }).slice('name', 'square_logo_url', 'user_max', 'wxqrcode', 'full_name', 'industry', 'sub_industry', 'location')
      self.verified_end_at = Time.at(corp_info['verified_end_time']) if corp_info['verified_end_time'].is_a? Numeric
    end

    def auth_info
      info = suite.api.auth_info(corpid, secret)
      assign_info(info)
      save
    end

    def sync_contacts
      items = api.list_contact_way.fetch('contact_way', [])
      items.each do |item|
        r = api.get_contact_way(item['config_id'])
        info = r['contact_way']
        info['user'].each do |user|
          contact = self.contacts.find_or_initialize_by(userid: user, config_id: item['config_id'])
          contact.assign_attributes info.slice('qr_code', 'remark', 'skip_verify', 'state')
          contact.save
        end
      end
    end

    def list_actived_account(debug: false)
      suite.provider.api.list_actived_account(corpid, debug: debug)
    end

    def list_codes
      orders = []
      codes = []

      r = suite.provider.api.list_order(corpid)
      r['order_list'].each do |h|
        account = suite.provider.api.list_order_account(h['order_id'])
        orders += account['account_list']
      end

      orders.each do |h|
        code = suite.provider.api.active_info_by_code(corpid, h['active_code'])
        codes << code['active_info']
      end

      codes
    end

    def js_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      js_hash = Wechat::Signature.signature(jsapi_ticket, url)
      js_hash.merge!(
        beta: true,
        appid: corpid
      )

      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

    def js_login(**url_options)
      url_options.with_defaults! controller: 'wechat/corps', action: 'login', id: id, host: host
      {
        appid: corpid,
        agentid: agentid,
        redirect_uri: ERB::Util.url_encode(Rails.application.routes.url_for(**url_options)),
        state: Com::State.create(host: host, controller: '/me/home')
      }
    end

    def agent_config(url = '/')
      refresh_agent_ticket unless agent_ticket_valid?
      js_hash = Wechat::Signature.signature(agent_ticket, url)
      js_hash.merge!(
        corpid: corpid,
        agentid: agentid
      )

      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

    def oauth2_url(scope: 'snsapi_privateinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/corps', action: 'login', id: id, host: organ.host
      h = {
        appid: corpid,
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
        info = suite.api.corp_token(corpid, secret)
      end
      self.access_token = info['access_token']
      self.access_token_expires_at = Time.current + info['expires_in'].to_i if info['access_token'] && self.access_token_changed?
      self.save
      info
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

    def sync_open_corpid!
      open = suite.provider.api.open_corpid(corpid)
      logger.debug "\e[35m  Suite Corp Open id: #{open}  \e[0m"
      self.open_corpid = open['open_corpid']
      self.save
    end

    def sync_supporters
      r = api.accounts
      r['account_list'].each do |item|
        supporter = supporters.find_or_initialize_by(open_kfid: item['open_kfid'])
        supporter.assign_attributes item.slice('name', 'avatar', 'manage_privilege')
        supporter.save
      end
    end

    def sync_departments
      r = api.department
      return unless r['errcode'] == 0
      r['department'].each do |dep|
        depart = organ.departments.find_or_initialize_by(wechat_id: dep['id'])
        depart.name = dep['name']
        depart.save
      end
    end

  end
end
