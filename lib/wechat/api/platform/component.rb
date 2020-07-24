module Wechat::Api::Platform::Component
  BASE = 'https://api.weixin.qq.com/cgi-bin/component/'

  def create_preauthcode
    body = {
      component_appid: app.appid
    }

    r = post 'api_create_preauthcode', body, base: BASE
    app.save_pre_auth_code(r)
    r
  end

  def query_auth(auth_code)
    body = {
      component_appid: app.appid,
      authorization_code: auth_code
    }
    r = post 'api_query_auth', body, base:BASE
    r['authorization_info']
  end


end
