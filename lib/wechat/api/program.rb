# frozen_string_literal: true

class Wechat::Api::Program < Wechat::Api::Base







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
