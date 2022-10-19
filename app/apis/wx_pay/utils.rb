module WxPay
  module Utils
    extend self

    def replace(string, params = {})
      string.scan(/{\w+}/).map do |match|
        r = match[1..-2]
        next unless params.key?(r.to_sym)
        string.gsub!(match, params.delete(r.to_sym).to_s)
      end

      string
    end

    def query(path, params = {})
      query = params.map do |k, v|
        "#{k}=#{v}" if v.to_s != ''
      end.join('&')
      if query.present?
        [path, query].join('?')
      else
        path
      end
    end

    def set_apiclient_by_pkcs12(str, pass)
      pkcs12 = OpenSSL::PKCS12.new(str, pass)
      @apiclient_cert = pkcs12.certificate
      @apiclient_key = pkcs12.key

      pkcs12
    end

    def apiclient_cert=(cert)
      @apiclient_cert = OpenSSL::X509::Certificate.new(cert)
    end

    def apiclient_key=(key)
      @apiclient_key = OpenSSL::PKey::RSA.new(key)
    end

  end
end
