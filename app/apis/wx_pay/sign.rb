require 'digest/md5'

module WxPay
  module Sign
    extend self

    def generate(params)
      key = params.delete(:key)

      new_key = params['key'] #after
      key = params.delete('key') if params['key'] #after

      query = params.sort.map do |k, v|
        "#{k}=#{v}" if v.to_s != ''
      end.compact.join('&')

      string_sign_temp = "#{query}&key=#{key || new_key || WxPay.key}" #after

      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, string_sign_temp).upcase
    end

  end
end
