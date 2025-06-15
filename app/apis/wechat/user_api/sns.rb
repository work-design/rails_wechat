class Wechat::UserApi
  module Sns
    BASE = 'https://api.weixin.qq.com/sns/'

    def userinfo(openid)
      get 'userinfo', origin: BASE, openid: openid
    end

    def refresh_token(refresh_token)
      params = {
        appid: app.appid,
        grant_type: 'refresh_token',
        refresh_token: refresh_token
      }

      r = client.with(origin: BASE).get 'oauth2/refresh_token', params: params
      JSON.parse(r)
    end

  end
end
