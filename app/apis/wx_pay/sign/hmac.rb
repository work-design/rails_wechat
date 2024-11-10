require 'openssl'

module WxPay::Sign
  module Hmac
    extend self

    def generate(params, key:)
      query = params.compact_blank.sort.map.each do |k, v|
        "#{k}=#{v}"
      end.join('&')
      string_sign_temp = "#{query}&key=#{key}"

      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, string_sign_temp).upcase
    end

    def generate_md5(params, key:)
      query = params.compact_blank.sort.map.each do |k, v|
        "#{k}=#{v}"
      end.join('&')
      string_sign_temp = "#{query}&key=#{key}"

      Digest::MD5.hexdigest(string_sign_temp).upcase
    end

  end
end
