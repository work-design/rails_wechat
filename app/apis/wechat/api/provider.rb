module Wechat::Api
  class Provider < Base
    include Service

    def provider_post(path, params: {}, headers: {}, base: nil, debug: nil, **payload)
      with_provider_access_token(params) do |with_token_params|
        @client.post_json path, payload, headers: headers, params: with_token_params, debug: debug, base: base
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
