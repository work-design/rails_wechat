require 'httpx'

module Wechat
  class HttpClient

    def initialize(base)
      @base = base
      timeout = RailsWechat.config.timeout
      
      @http = HTTPX.timeout(connect: timeout, write: timeout, read: timeout)
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.ssl_version = :TLSv1
      @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE if RailsWechat.config.skip_verify_ssl
    end

    def get(path, headers: {}, params: {}, base: '')
      headers['Accept'] ||= 'application/json'
      
      request(path, base: base) do |url|
        @http.headers(headers).get(url, params: params, ssl_context: @ssl_context)
      end
    end

    def post(path, payload, headers: {}, params: {}, base: '')
      headers['Accept'] ||= 'application/json'
      
      request(path, base: base) do |url|
        @http.headers(headers).post(url, params: params, body: payload, ssl_context: @ssl_context)
      end
    end

    def post_file(path, file, headers: {}, params: {}, base: '')
      headers['Accept'] ||= 'application/json'
      
      request(path, base: base) do |url|
        form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file)
        @http.headers(headers).post(
          url,
          params: params,
          form: { media: form_file, hack: 'X' }, # Existing here for http-form_data 1.0.1 handle single param improperly
          ssl_context: @ssl_context
        )
      end
    end

    private
    def request(path, base: @base, as: :json, &_block)
      response = yield("#{base}#{path}")

      raise "Request not OK, response status #{response.status}" if response.status != 200
      parse_response(response, as || :json) do |parse_as, data|
        break data unless parse_as == :json && data['errcode'].present?

        case data['errcode']
        when 0 # for request didn't expect results
          data
        # 42001: access_token timeout
        # 40014: invalid access_token
        # 40001, invalid credential, access_token is invalid or not latest hint
        # 48001, api unauthorized hint, should not handle here # GH-230
        when 42001, 40014, 40001
          raise AccessTokenExpiredError
        # 40029, invalid code for mp # GH-225
        # 43004, require subscribe hint # GH-214
        else
          raise ResponseError.new(data['errcode'], data['errmsg'])
        end
      end
    end

    def parse_response(response, as)
      content_type = response.content_type.mime_type
      parse_as = {
        /^application\/json/ => :json,
        /^image\/.*/ => :file,
        /^audio\/.*/ => :file,
        /^voice\/.*/ => :file,
        /^text\/html/  => :xml,
        /^text\/plain/ => :probably_json
      }.each_with_object([]) { |match, memo| memo << match[1] if content_type =~ match[0] }.first || as || :text

      # try to parse response as json, fallback to user-specified format or text if failed
      if parse_as == :probably_json
        data = JSON.parse response.body.to_s.gsub(/[\u0000-\u001f]+/, '') rescue nil
        if data
          return yield(:json, data)
        else
          parse_as = as || :text
        end
      end

      case parse_as
      when :file
        file = Tempfile.new('tmp')
        file.binmode
        file.write(response.body)
        file.close
        data = file
      when :json
        data = JSON.parse response.body.to_s.gsub(/[\u0000-\u001f]+/, '')
      when :xml
        data = Hash.from_xml(response.body.to_s)
      else
        data = response.body
      end

      yield(parse_as, data)
    end
  end
end
