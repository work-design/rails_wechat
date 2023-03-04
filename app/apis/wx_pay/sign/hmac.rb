require 'openssl'

module WxPay::Sign
  module Hmac
    extend self

    def generate(params, key:)
      query = params.compact_blank.sort.map.each do |k, v|
        "#{k}=#{v}"
      end.join('&')
      string_sign_temp = "#{query}&key=#{key}"
      Rails.logger.debug "---- #{string_sign_temp}"

      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, string_sign_temp).upcase
    end

  end
end
