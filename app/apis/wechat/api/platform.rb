module Wechat::Api
  class Platform < Wechat::Api::Base
    include Component

    protected
    def with_access_token(params = {}, tries = 2)
      app.refresh_access_token unless app.access_token_valid?
      yield params.merge!(component_access_token: app.access_token)
    rescue Wechat::AccessTokenExpiredError
      app.refresh_access_token
      retry unless (tries -= 1).zero?
    end

  end
end
