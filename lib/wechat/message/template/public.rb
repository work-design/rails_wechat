class Wechat::Message::Template::Public < Wechat::Message::Template
  

  def to(openid, **options)
    @message_hash.merge!(touser: openid, **options)
  end

  def template(opts = {})
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    @message_hash.merge!(MsgType: 'template', Template: template_fields)
  end
  
end
