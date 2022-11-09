module Wechat::Api
  class Provider < Base
    include Service

    def provider_post(path, params: {}, headers: {}, origin: nil, debug: nil, **payload)
      with_options = { origin: origin }
      with_options.merge! debug: STDERR, debug_level: 2 if debug

      with_provider_access_token(params) do |with_token_params|
        with_token_params.merge! debug: 1 if debug
        response = @client.with_headers(headers).with(with_options).post(path, params: with_token_params, json: payload)
        debug ? response : parse_response(response)
      end
    end

    def with_provider_access_token(params = {}, tries = 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(provider_access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
