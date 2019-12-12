class Wechat::Message::Push::Public < Wechat::Message::Push
  
  # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1481187827_i0l21
  MSG_TYPE = [
    'mpnews', 'voice', 'image', 'mpvideo',  # media_id
    'text',  # content
    'wxcard'  # card_id
  ].freeze

  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
  def to_mass(tag_id = nil, **options)
    if tag_id
      @message_hash.merge!(filter: { is_to_all: false, tag_id: tag_id }, **options)
    else
      @message_hash.merge!(filter: { is_to_all: true }, **options)
    end
  end
  
  def do_send
    api.post 'message/mass/sendall', @message_hash
    api.post 'message/mass/send', @message_hash
  end

  def to(*openid, **options)
    raise 'must send to more than 2 uses!' if openid.size < 2
    @message_hash.merge!(touser: openid, **options)
  end

  def template(opts = {})
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    @message_hash.merge!(MsgType: 'template', Template: template_fields)
  end
  
end
