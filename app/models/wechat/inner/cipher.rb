module Wechat
  module Inner::Cipher
    extend ActiveSupport::Concern

    included do
      attribute :encoding_aes_key, :string, default: SecureRandom.alphanumeric(43)
    end

    def init_aes_key
      self.encoding_aes_key = SecureRandom.alphanumeric(43)
    end

    def decrypt(encrypt_data)
      Wechat::Cipher.decrypt(encrypt_data, encoding_aes_key)
    end

    def encrypt(data)
      x = Wechat::Cipher.encrypt(Wechat::Cipher.pack(data, appid), encoding_aes_key)
      Base64.strict_encode64(x)
    end

  end
end
