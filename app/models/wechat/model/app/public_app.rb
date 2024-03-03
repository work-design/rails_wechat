module Wechat
  module Model::App::PublicApp
    extend ActiveSupport::Concern

    included do
      attribute :weapp_id, :string, comment: '关联的小程序'

      belongs_to :weapp, class_name: 'ProgramApp', foreign_key: :weapp_id, primary_key: :appid, optional: true
    end

    def oauth2_url(scope: 'snsapi_userinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', appid: appid, host: self.oauth_domain.presence || domain
      h = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state
      }
      logger.debug "\e[35m  App Oauth2: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def oauth2_data_url(scope = 'snsapi_base', **host_options)
      r = oauth2_url(scope: scope, **host_options)
      QrcodeHelper.data_url(r)
    end

    def generate_wechat_user(code)
      result = api.oauth2_access_token(code)
      logger.debug "\e[35m  Public App Generate User: #{result}  \e[0m"

      wechat_user = WechatUser.find_or_initialize_by(uid: result['openid'])
      wechat_user.appid = appid
      wechat_user.assign_attributes result.slice('access_token', 'refresh_token', 'scope', 'unionid')
      wechat_user.expires_at = Time.current + result['expires_in'].to_i
      wechat_user.init_user
      wechat_user
    end

  end
end
