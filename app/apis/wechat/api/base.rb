# frozen_string_literal: true
require 'httpx'
require 'http/form_data'

module Wechat::Api
  class Base
    attr_reader :app, :client

    def initialize(app)
      @app = app
      @client = Wechat::HttpClient.new
      @client = HTTPX.with(**RailsWechat.config.httpx)
    end

    def get(path, params: {}, headers: {}, origin: nil, debug: nil)
      with_access_token(params) do |with_token_params|
        @client.get path, headers: headers, params: with_token_params, base: base, debug: debug
      end
    end

    def getx(path, headers: {}, params: {}, base: nil, **options)
      headers.with_defaults! 'Accept' => 'application/json'
      url = base + path

      response = @http.with_headers(headers).get(url, params: params)

      if options[:debug]
        response
      else
        parse_response(response)
      end
    end

    def post(path, params: {}, headers: {}, base: nil, debug: nil, **payload)
      with_access_token(params) do |with_token_params|
        @client.post_json path, payload, headers: headers, params: with_token_params, debug: debug, base: base
      end
    end

    def post_file(path, file, params: {}, headers: {}, base: nil, **options)
      with_access_token(params) do |with_token_params|
        @client.post_file path, file, headers: headers, params: with_token_params, base: base, **options
      end
    end

    protected
    def with_access_token(params = {}, tries = 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

    def parse_response(response)
      raise "Request get fail, response status #{response.status}" if response.status != 200

      content_type = response.content_type.mime_type
      body = response.body.to_s

      if content_type =~ /image|audio|video/
        data = Tempfile.new('tmp')
        data.binmode
        data.write(body)
        data.rewind
        return data
      elsif content_type =~ /html|xml/
        data = Hash.from_xml(body)
      else
        data = JSON.parse body.gsub(/[\u0000-\u001f]+/, '')
      end

      case data['errcode']
      when 0
        data
        # 42001: access_token timeout
        # 40014: invalid access_token
        # 40001, invalid credential, access_token is invalid or not latest hint
        # 48001, api unauthorized hint, should not handle here # GH-230
        # 40082, 企业微信
      when 42001, 40014, 40001, 41001, 40082
        raise Wechat::AccessTokenExpiredError, data
      else
        data
      end
    end

  end
end
