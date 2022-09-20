module Wechat
  module Model::Provider
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string
      attribute :provider_secret, :string
      attribute :token, :string
      attribute :encoding_aes_key, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime

      has_many :corp_users
      has_many :corps
      has_many :suites, foreign_key: :corp_id, primary_key: :corp_id
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

    def api
      return @api if defined? @api
      @api = Wechat::Api::Provider.new(self)
    end

    def refresh_access_token
      r = api.token
      if r['provider_access_token']
        self.access_token = r['provider_access_token']
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

    def init_by_auth_code(auth_code)
      r = api.login_info(auth_code)
      if r['errcode']
        logger.debug "#{r['errmsg']}"
        return
      end

      user_info = r.dig('user_info')
      corp_user = corp_users.find_or_initialize_by(open_userid: user_info['open_userid'])
      corp_user.corp_id = r.dig('corp_info', 'corpid')
      corp_user.user_id = user_info['userid']
      corp_user.avatar_url = user_info['avatar']
      corp_user
    end

  end
end
