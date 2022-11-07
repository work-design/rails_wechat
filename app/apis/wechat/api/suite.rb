module Wechat::Api
  class Suite < Wechat::Api::Base
    include Service
    include IdConvert

    def raw_post(path, params: {}, headers: {}, base: nil, debug: nil, **payload)
      r = with_raw_access_token(params) do |with_token_params|
        @client.post_json path, payload, headers: headers, params: with_token_params, debug: debug, base: base
      end
      Rails.logger.debug "\e[35m  #{r}  \e[0m"
      r
    end

    protected
    def with_access_token(params = {}, tries = 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(suite_access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

    def with_raw_access_token(params = {}, tries = 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
