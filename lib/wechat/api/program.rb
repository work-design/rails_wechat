# frozen_string_literal: true

class Wechat::Api::Program < Wechat::Api::Base
  WXAAPI = 'https://api.weixin.qq.com/wxaapi/'
  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
  def msg_sec_check(content)
    post 'msg_sec_check', { content: content }, base: WXA_BASE
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/template-message/templateMessage.getTemplateList.html
  def templates
    r = get 'newtmpl/gettemplate', base: WXAAPI
    r['data']
  end
  
  def template_send
    post 'message/subscribe/send', {}, base: API_BASE
  end

  def get_wxacode(path, width = 430)
    post 'getwxacode', path: path, width: width, base: WXA_BASE
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
  def jscode2session(code)
    params = {
      appid: app.appid,
      secret: app.secret,
      js_code: code,
      grant_type: 'authorization_code'
    }

    get 'jscode2session', params: params, base: SNS_BASE
  end

end
