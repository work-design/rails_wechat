module Wechat
  module Model::WechatApp::WechatRead
    extend ActiveSupport::Concern

    included do

    end


    def oauth2_url(scope = 'snsapi_userinfo', **host_options)
      options = Rails.application.routes.default_url_options
      h = {
        appid: appid,
        redirect_uri: url_helpers.wechat_app_url(id, **options),
        response_type: 'code',
        scope: scope,
        state: SecureRandom.hex(16)
      }
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end


  end
end
