# frozen_string_literal: true

module Wechat::Api
  class Base
    attr_reader :app, :client

    def initialize(app)
      @app = app
      @client = Wechat::HttpClient.new
    end

    def get(path, params: {}, headers: {}, base: nil, debug: nil)
      with_access_token(params) do |with_token_params|
        @client.get path, headers: headers, params: with_token_params, base: base, debug: debug
      end
    end

    def post(path, params: {}, headers: {}, base: nil, debug: nil, **payload)
      with_access_token(params) do |with_token_params|
        @client.post path, payload.to_json, headers: headers, params: with_token_params, debug: debug, base: base
      end
    end

    def post_file(path, file, params: {}, headers: {}, base: nil, debug: nil)
      with_access_token(params) do |with_token_params|
        @client.post_file path, file, headers: headers, params: with_token_params, base: base, debug: debug
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

  end
end
