# frozen_string_literal: true

class Wechat::Api::Program < Wechat::Api::Base

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
  def msg_sec_check(content)
    post 'msg_sec_check', { content: content }, base: WXA_BASE
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/template-message/templateMessage.getTemplateList.html
  def list_message_template(offset: 0, count: 20)
    post 'newtmpl/gettemplate', offset: offset, count: count, base: WXAAPI
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
