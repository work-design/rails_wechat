class Wechat::BaseApi
  module Sns
    BASE = 'https://api.weixin.qq.com/sns/'

    def oauth2_access_token(code)
      params = {
        appid: app.appid,
        secret: app.secret,
        code: code,
        grant_type: 'authorization_code'
      }
      get 'oauth2/access_token', origin: BASE, **params
    end

    def web_auth_access_token(web_access_token, openid)
      get 'auth', origin: BASE, access_token: web_access_token, openid: openid
    end

    def web_userinfo(web_access_token, openid, lang = 'zh_CN')
      get 'userinfo', origin: BASE, access_token: web_access_token, openid: openid, lang: lang
    end

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
    def jscode2session(code)
      params = {
        appid: app.appid,
        secret: app.secret,
        js_code: code,
        grant_type: 'authorization_code'
      }

      get 'jscode2session', origin: BASE, **params
    end

  end
end
