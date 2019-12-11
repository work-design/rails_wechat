require 'httpx'

module Wechat
  class HttpClient

    def initialize(base)
      @base = base
      @http = HTTPX.timeout(**RailsWechat.config.httpx_timeout)
      @http.with(ssl: RailsWechat.config.httpx_ssl)
    end

    def get(path, headers: {}, params: {}, **options)
      headers['Accept'] ||= 'application/json'
      @base = options[:base] if options[:base]
      url = @base + path

      response = @http.headers(headers).get(url, params: params)
      parse_response(response, parse_as)
    end

    def post(path, payload, headers: {}, params: {}, **options)
      headers['Accept'] ||= 'application/json'
      @base = options[:base] if options[:base]
      url = @base + path

      response = @http.headers(headers).post(url, params: params, body: payload)
      parse_response(response, parse_as)
    end

    def post_file(path, file, headers: {}, params: {}, **options)
      headers['Accept'] ||= 'application/json'
      @base = options[:base] if options[:base]
      url = @base + path

      form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file)
      response = @http.headers(headers).post(
        url,
        params: params,
        form: { media: form_file, hack: 'X' } # Existing here for http-form_data 1.0.1 handle single param improperly
      )
      parse_response(response, parse_as)
    end

    private
    def parse_response(response, parse_as)
      raise "Request not OK, response status #{response.status}" if response.status != 200

      content_type = MiniMime.lookup_by_content_type(response.content_type.mime_type).extension
      if content_type.binary?
        parse_as = :file
      else
        parse_as = content_type.to_sym
      end

      case parse_as
      when :file
        data = Tempfile.new('tmp')
        data.binmode
        data.write(response.body)
        data.close
        data
      when :html, :xml
        data = Hash.from_xml(response.body.to_s)
      else
        data = JSON.parse response.body.to_s.gsub(/[\u0000-\u001f]+/, '')
      end

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
      when 2
        raise ResponseError.new(data['errcode'], data['errmsg'])
      else
        data
      end
    end

  end
end
