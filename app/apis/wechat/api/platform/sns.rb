module Wechat::Api
  module Platform::Sns
    BASE = 'https://api.weixin.qq.com/sns/component/'

    # https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/login/thirdpartyCode2Session.html
    def jscode2session(appid, code)
      params = {
        appid: appid,
        grant_type: 'authorization_code',
        component_appid: app.component_appid,
        js_code: code
      }

      get 'jscode2session', params: params, origin: BASE
    end

  end
end
