module Wechat
  class PlatformApi < BaseApi
    include Component
    include Sns
    include Wxa

    def component_get(path, params: {}, headers: {}, origin: nil, debug: nil)
      with_options = { origin: origin }
      with_options.merge! debug: STDERR, debug_level: 2 if debug

      with_component_access_token(params: params) do
        response = @client.with_headers(headers).with(with_options).get(path, params: params)
        debug ? response : parse_response(response)
      end
    end

    def component_post(path, params: {}, headers: {}, origin: nil, debug: nil, **payload)
      with_options = { origin: origin }
      with_options.merge! debug: STDERR, debug_level: 2 if debug

      with_component_access_token(params: params) do
        params.merge! debug: 1 if debug
        response = @client.with_headers(headers).with(with_options).post(path, params: params, json: payload)
        debug ? response : parse_response(response)
      end
    end

    protected
    def with_component_access_token(params: {}, headers: {}, payload: {}, tries: 2)
      app.refresh_access_token unless app.access_token_valid?
      params.merge!(component_access_token: app.access_token)
      yield
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

    def with_access_token(params: {}, headers: {}, payload: {}, tries: 2)
      app.refresh_access_token unless app.access_token_valid?
      params.merge!(access_token: app.access_token)
      yield
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
