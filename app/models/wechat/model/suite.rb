module Wechat
  module Model::Suite
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string
      attribute :suite_id, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :suite_ticket, :string
      attribute :suite_ticket_pre, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :pre_auth_code, :string
      attribute :pre_auth_code_expires_at, :datetime
      attribute :redirect_controller, :string
      attribute :redirect_action, :string, default: 'index', comment: '默认跳转'

      belongs_to :provider, foreign_key: :corp_id, primary_key: :corp_id

      has_many :suite_tickets
      has_many :suite_receives, foreign_key: :suite_id, primary_key: :suite_id
      has_many :corp_users, foreign_key: :suite_id, primary_key: :suite_id
      has_many :corps, foreign_key: :suite_id, primary_key: :suite_id
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

    def oauth2_url(scope: 'snsapi_userinfo', state: SecureRandom.hex(16), host:, **url_options)
      url_options.with_defaults! controller: 'wechat/suites', action: 'login', id: id, host: host
      h = {
        appid: suite_id,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state
      }

      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def install_url(state: SecureRandom.hex(16), host:, **host_options)
      refresh_pre_auth_code unless pre_auth_code_valid?
      h = {
        suite_id: suite_id,
        pre_auth_code: pre_auth_code,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/providers', action: 'login', id: id, host: host, **host_options),
        state: state
      }

      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.work.weixin.qq.com/3rdapp/install?#{h.to_query}"
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Suite.new(self)
    end

    def refresh_pre_auth_code
      r = api.pre_auth_code
      if r['pre_auth_code']
        self.pre_auth_code = r['pre_auth_code']
        self.pre_auth_code_expires_at = Time.current + r['expires_in'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def pre_auth_code_valid?
      return false unless pre_auth_code_expires_at.acts_like?(:time)
      pre_auth_code_expires_at > Time.current
    end

    def refresh_access_token
      r = api.token
      if r['suite_access_token']
        self.access_token = r['suite_access_token']
        self.access_token_expires_at = Time.current + r['expires_in'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def access_token_valid?
      return false unless access_token_expires_at.acts_like?(:time)
      access_token_expires_at > Time.current
    end

    def generate_corp_user(code)
      refresh_access_token unless access_token_valid?

      h = {
        code: code,
        suite_access_token: access_token
      }
      r = HTTPX.get "https://qyapi.weixin.qq.com/cgi-bin/service/getuserinfo3rd?#{h.to_query}"
      result = JSON.parse(r.body.to_s)
      if result['errcode'] == 40082
        refresh_access_token && generate_corp_user(code)
      end

      logger.debug "\e[35m  #{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(open_userid: result['open_userid'])
      corp_user.corp_id = result['CorpId']
      corp_user.user_id = result['UserId']
      corp_user.device_id = result['DeviceId']
      corp_user.user_ticket = result['user_ticket']
      corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
      corp_user.open_id = result['OpenId']
      corp_user
    end

    def generate_corp(auth_code)
      r = api.permanent_code(auth_code)
      if r['errcode']
        logger.debug "#{r['errmsg']}"
        return
      end

      corp_id = r.dig('auth_corp_info', 'corpid')
      corp = corps.find_or_initialize_by(corp_id: corp_id)
      corp.assign_info(r)
      corp.save
      corp
    end

  end
end
