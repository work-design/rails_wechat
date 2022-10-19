require 'openssl'

module WxPay
  module Sign
    module Rsa
      extend self

      def generate(method, path, params, **options)
        if method == 'GET'
          body = nil
        else
          body = params.to_json
        end
        binding.b
        str = [
          method,
          path,
          options[:timestamp],
          options[:nonce_str],
          body
        ].join("\n") + "\n"

        sign(str, options[:key])
      end

      # key 为 apiclient_key.pem 的内容
      def sign(string, key)
        digest = OpenSSL::Digest::SHA256.new
        pkey = OpenSSL::PKey::RSA.new(key)
        signature = pkey.sign(digest, string)

        Base64.strict_encode64(signature)
      end

    end
  end
end
