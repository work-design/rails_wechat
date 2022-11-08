module Wechat::Api
  module Base::Sns
    BASE = 'https://api.weixin.qq.com/sns/'

    def web_access_token(code)
      params = {
        appid: access_token.appid,
        secret: access_token.secret,
        code: code,
        grant_type: 'authorization_code'
      }
      get 'oauth2/access_token', params: params, origin: BASE
    end

    def web_auth_access_token(web_access_token, openid)
      get 'auth', params: { access_token: web_access_token, openid: openid }, origin: BASE
    end

    def web_userinfo(web_access_token, openid, lang = 'zh_CN')
      get 'userinfo', params: { access_token: web_access_token, openid: openid, lang: lang }, origin: BASE
    end

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
    def jscode2session(code)
      params = {
        appid: app.appid,
        secret: app.secret,
        js_code: code,
        grant_type: 'authorization_code'
      }

      get 'jscode2session', params: params, origin: BASE
    end

  end
end
