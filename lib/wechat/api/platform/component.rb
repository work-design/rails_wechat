module Wechat::Api::Platform::Component
  BASE = 'https://api.weixin.qq.com/cgi-bin/component'

  def api_create_preauthcode
    body = {
      component_appid: app.appid
    }

    post 'api_create_preauthcode', body, base: BASE
  end


end
