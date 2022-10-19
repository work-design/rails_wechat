module WxPay
  module Cipher
    extend self

    def decrypt(data, key:, iv:, auth_data:, type: 'AES-256-GCM')
      data = Base64.decode64(data)
      cipher = OpenSSL::Cipher.new(type)
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_data = auth_data
      cipher.auth_tag = data[-16..-1]

      cipher.update(data[0..-17]) + cipher.final
    end

    def decrypt_notice(params, key:)
      data = params['ciphertext']
      iv = params['nonce']
      auth_data = params['associated_data']

      r = decrypt(data, key: key, iv: iv, auth_data: auth_data)
      JSON.parse r
    end

    def rsa_encrypt(data, key:)
      cipher = OpenSSL::Cipher.new('AES-256-GCM')
      cipher.encrypt
      cipher.padding = OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING
      cipher.key = key
      cipher.iv = ''
      cipher.update(data) + cipher.final

      Base64.encode64(r)
    end

  end
end
