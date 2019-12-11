module Wechat::Api::Xxx::Sns

  def web_access_token(code)
    params = {
      appid: access_token.appid,
      secret: access_token.secret,
      code: code,
      grant_type: 'authorization_code'
    }
    get 'oauth2/access_token', params: params, base: SNS_BASE
  end

  def web_auth_access_token(web_access_token, openid)
    get 'auth', params: { access_token: web_access_token, openid: openid }, base: SNS_BASE
  end

  def web_refresh_access_token(user_refresh_token)
    params = {
      appid: access_token.appid,
      grant_type: 'refresh_token',
      refresh_token: user_refresh_token
    }
    get 'oauth2/refresh_token', params: params, base: SNS_BASE
  end

  def web_userinfo(web_access_token, openid, lang = 'zh_CN')
    get 'userinfo', params: { access_token: web_access_token, openid: openid, lang: lang }, base: SNS_BASE
  end

end
