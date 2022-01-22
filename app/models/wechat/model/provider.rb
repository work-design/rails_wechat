module Wechat
  module Model::Provider
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string
      attribute :provider_secret, :string
      attribute :suite_id, :string
      attribute :secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :suite_ticket, :string
      attribute :suite_ticket_pre, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime

      has_many :provider_receives
      has_many :corp_users
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

    def oauth2_url(scope = 'snsapi_userinfo', state: SecureRandom.hex(16), host: self.host, **host_options)
      h = {
        appid: suite_id,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/apps', action: 'login', id: id, host: host, **host_options),
        response_type: 'code',
        scope: scope,
        state: state
      }
      logger.debug "\e[35m  Detail: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Suite.new(self)
    end

    def refresh_access_token
      r = api.token
      if r['suite_access_token']
        store_access_token(r)
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
      end
    end

    def store_access_token(token_hash)
      self.access_token = token_hash['suite_access_token']
      self.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
      self.save
    end

    def generate_corp_user(code)
      h = {
        code: code,
        suite_access_token: suite_access_token
      }
      r = HTTPX.get "https://qyapi.weixin.qq.com/cgi-bin/service/getuserinfo3rd?#{h.to_query}"
      result = JSON.parse(r.body.to_s)

      corp_user = corp_users.find_or_initialize_by(uid: result['openid'])
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user.sync_user_info if wechat_user.access_token.present? && (wechat_user.attributes['name'].blank? && wechat_user.attributes['avatar_url'].blank?)
      wechat_user
    end

  end
end
