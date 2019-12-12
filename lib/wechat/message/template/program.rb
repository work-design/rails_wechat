class Wechat::Message::Template::Program < Wechat::Message::Template
  
  def to(openid, **options)
    @message_hash.merge!(touser: openid, **options)
  end
  
  def do_send
    api.post 'message/subscribe/send', {}, base: API_BASE
  end

  def templatess(opts = {})
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    @message_hash.merge!(MsgType: 'template', Template: template_fields)
  end

end
