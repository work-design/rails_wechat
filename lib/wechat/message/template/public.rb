class Wechat::Message::Template::Public < Wechat::Message::Template

  def do_send

  end

  def to_message
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    @message_hash.merge!(MsgType: 'template', Template: template_fields)
  end

end
