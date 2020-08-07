module RailsWechat::WechatNotice::PublicNotice
  BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def do_send
    r = wechat_app.api.post 'message/template/send', **message_hash, base: BASE
  end

  def message_hash
    {
      touser: wechat_user.uid,
      template_id: wechat_template.template_id,
      url: link,
      data: data
    }
  end

end
