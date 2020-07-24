module Wechat::Api::Platform::Component
  BASE = 'https://api.weixin.qq.com/cgi-bin/component'

  def api_component_token
    body = {
      component_appid: app.appid,
      component_appsecret: app.secret,
      component_verify_ticket: app.verify_ticket
    }

    post 'api_component_token', body, base: BASE
  end

end
