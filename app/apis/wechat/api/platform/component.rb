module Wechat::Api
  module Platform::Component
    BASE = 'https://api.weixin.qq.com/cgi-bin/component/'

    def create_preauthcode
      body = {
        component_appid: app.appid
      }

      post 'api_create_preauthcode', **body, origin: BASE
    end

    def query_auth(auth_code)
      body = {
        component_appid: app.appid,
        authorization_code: auth_code
      }

      r = post 'api_query_auth', **body, origin: BASE
      Rails.logger.debug "\e[35m  query path #{r}  \e[0m"
      r['authorization_info'] if r.present?
    end

    def authorizer_token(appid, refresh_token)
      body = {
        component_appid: app.appid,
        authorizer_appid: appid,
        authorizer_refresh_token: refresh_token
      }

      post 'api_authorizer_token', **body, origin: BASE
    end

    def get_authorizer_info(appid)
      body = {
        component_appid: app.appid,
        authorizer_appid: appid
      }

      r = post 'api_get_authorizer_info', **body, origin: BASE
      r['authorizer_info']
    end

    def component_token
      r = client.with(origin: BASE).post(
        'api_component_token',
        json: {
          component_appid: app.appid,
          component_appsecret: app.secret,
          component_verify_ticket: app.verify_ticket
       }
      )

      r.json
    end

    def oauth2_access_token(code, appid)
      params = {
        appid: appid,
        code: code,
        grant_type: 'authorization_code',
        component_appid: app.appid,
      }
      get 'oauth2/component/access_token', params: params, origin: 'https://api.weixin.qq.com/sns/'
    end

  end
end
