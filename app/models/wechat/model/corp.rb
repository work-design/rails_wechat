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
      attribute :permanent_code, :string
      attribute :suite_id, :string
      attribute :host, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string

      belongs_to :organ_domain, class_name: 'Org::OrganDomain', foreign_key: :host, primary_key: :identifier
      has_one :organ, class_name: 'Org::Organ', through: :organ_domain

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true
      belongs_to :provider, optional: true

      has_many :corp_tickets, ->(o) { where(suiteid: o.suite_id) }
      has_many :corp_users, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id
      has_many :contacts, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id
      has_many :externals, foreign_key: :corp_id, primary_key: :corp_id

      after_validation :init_organ, if: -> { corp_id_changed? }
    end

    # 密文解密得到msg的过程
    # https://open.work.weixin.qq.com/api/doc/90000/90139/90968#密文解密得到msg的过程
    def decrypt(msg)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.padding = 0

      # AES 采用 CBC 模式，数据采用 PKCS#7 填充至 32 字节的倍数；
      aes_key = Base64.decode64(encoding_aes_key + '=')
      cipher.key = aes_key
      # IV 初始向量大小为 16 字节，取 AESKey 前 16 字节，详见：http://tools.ietf.org/html/rfc2315
      cipher.iv = aes_key[0, 16]
      plain = cipher.update(Base64.decode64(msg)) + cipher.final

      content, _ = Wechat::Cipher.unpack(plain)
      content
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
      organ
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
      self.verified_end_at = Time.at(corp_info['verified_end_time'])
    end

    def auth_info
      info = provider.api.auth_info(corp_id, permanent_code)
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

    def agentid
      agent['agentid']
    end

    def agent_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      page_url = url.delete_suffix('#')
      js_hash = Wechat::Signature.signature(jsapi_ticket, page_url)
      js_hash.merge!(
        corpid: corp_id,
        agentid: agentid
      )

      logger.debug "\e[35m  Current page is: #{page_url}, Hash: #{js_hash.inspect}  \e[0m"
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

    def refresh_jsapi_ticket
      info = api.agent_ticket
      self.jsapi_ticket = info['ticket']
      self.jsapi_ticket_expires_at = Time.current + info['expires_in'].to_i if info['ticket'] && self.jsapi_ticket_changed?
      self.save
      info
    end

    def jsapi_ticket_valid?
      return false unless jsapi_ticket_expires_at.acts_like?(:time)
      jsapi_ticket_expires_at > Time.current
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Work.new(self)
    end

  end
end
