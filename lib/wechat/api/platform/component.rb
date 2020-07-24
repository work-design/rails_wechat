module Wechat::Api::Platform::Component
  BASE = 'https://api.weixin.qq.com/cgi-bin/component/'

  def api_create_preauthcode
    body = {
      component_appid: app.appid
    }

    r = post 'api_create_preauthcode', body, base: BASE
    app.save_pre_auth_code(r)
    r
  end


end
