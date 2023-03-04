require 'openssl'

module WxPay::Sign
  module Hmac
    extend self

    def generate(params, key:)
      query = params.compact_blank.sort.to_query
      string_sign_temp = "#{query}&key=#{key}"

      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, string_sign_temp).upcase
    end

  end
end
