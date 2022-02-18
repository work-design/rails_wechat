module Wechat::Api
  class Provider < Wechat::Api::Base
    include Service

    protected
    def with_access_token(params = {}, tries = 2)
      app.refresh_provider_access_token unless app.provider_access_token_valid?
      yield params.merge!(access_token: app.provider_access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_provider_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
