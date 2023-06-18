module Wechat::Api
  module Platform::Sns
    BASE = 'https://api.weixin.qq.com/sns/'

    # https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/login/thirdpartyCode2Session.html
    def jscode2session(appid, code)
      params = {
        appid: appid,
        grant_type: 'authorization_code',
        component_appid: app.appid,
        js_code: code
      }

      component_get 'component/jscode2session', params: params, origin: BASE
    end

    def oauth2_access_token(code, appid)
      params = {
        appid: appid,
        code: code,
        grant_type: 'authorization_code',
        component_appid: app.appid,
      }
      component_get 'oauth2/component/access_token', params: params, origin: BASE
    end

  end
end
