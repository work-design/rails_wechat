module Wechat
  module Model::App::Agency
    extend ActiveSupport::Concern

    def refresh_access_token
      r = platform.api.authorizer_token(appid, refresh_token)
      store_access_token(r)
    end

  end
end
