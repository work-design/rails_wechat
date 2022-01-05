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


  end
end
