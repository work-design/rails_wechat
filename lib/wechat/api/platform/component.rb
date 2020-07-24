module Wechat::Api::Platform::Component
  BASE = 'https://api.weixin.qq.com/cgi-bin/component'

  def api_create_preauthcode(appid)
    body = {
      component_appid: appid
    }

    post 'api_create_preauthcode', body, base: BASE
  end


end
