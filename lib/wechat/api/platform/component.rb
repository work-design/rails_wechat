module Wechat::Api::Platform::Component
  PLATFORM_BASE = 'https://api.weixin.qq.com/cgi-bin/component'

  def api_component_token
    body = {
      component_appid: app.appid,
      component_appsecret: app.secret,
      component_verify_ticket: app.verify_ticket
    }

    post 'api_component_token', body
  end

end
