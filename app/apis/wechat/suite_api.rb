module Wechat
  class SuiteApi < BaseApi
    include Service

    def raw_post(path, params: {}, headers: {}, origin: nil, debug: nil, **payload)
      with_options = { origin: origin }
      with_options.merge! debug: STDERR, debug_level: 2 if debug

      r = with_raw_access_token(params: params) do |with_token_params|
        with_token_params.merge! debug: 1 if debug
        response = @client.with_headers(headers).with(with_options).post(path, params: with_token_params, json: payload)
        debug ? response : parse_response(response)
      end
      Rails.logger.debug "\e[35m  #{r}  \e[0m"
      r
    end

    protected
    def with_access_token(params: {}, headers: {}, payload: {}, tries: 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(suite_access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

    def with_raw_access_token(params: {}, tries: 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
