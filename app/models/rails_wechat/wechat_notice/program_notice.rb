module RailsWechat::WechatNotice::ProgramNotice
  BASE = 'https://api.weixin.qq.com/cgi-bin/'
  extend ActiveSupport::Concern

  included do
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
  def do_send
    wechat_app.api.post 'message/subscribe/send', **message_hash, base: BASE
  end

  def message_hash
    {
      template_id: wechat_template.template_id,
      touser: wechat_user.uid,
      data: data
    }
  end

end
