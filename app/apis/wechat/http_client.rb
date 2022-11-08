require 'httpx'
require 'http/form_data'

module Wechat
  class HttpClient
    attr_reader :http

    def initialize
      @http = HTTPX.with(**RailsWechat.config.httpx)
    end



    def post(path, payload, headers: {}, params: {}, base: nil, **options)
      headers.with_defaults! 'Accept' => 'application/json', 'Content-Type' => 'application/json'
      url = base + path

      response = @http.with_headers(headers).post(url, params: params, body: payload)

      if options[:debug]
        response
      else
        parse_response(response)
      end
    end

    def post_json(path, payload, headers: {}, params: {}, base: nil, **options)
      url = base + path
      response = @http.with_headers(headers).post(url, params: params, json: payload)

      if options[:debug]
        response
      else
        parse_response(response)
      end
    end

    def post_file(path, file, headers: {}, params: {}, base: nil, **options)
      headers.with_defaults! 'Accept' => 'application/json'
      url = base + path

      form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file, content_type: options[:content_type])
      response = @http.plugin(:multipart).with_headers(headers).post(
        url,
        params: params,
        form: { media: form_file }
      )
      if options[:debug]
        response
      else
        parse_response(response)
      end
    end

  end
end
