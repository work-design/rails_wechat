class Wechat::Message::Push::Public < Wechat::Message::Push
  
  # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1481187827_i0l21
  MSG_TYPE = [
    'mpnews', 'voice', 'image', 'mpvideo',  # media_id
    'text',  # content
    'wxcard'  # card_id
  ].freeze

  # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1481187827_i0l21
  def to_mass(tag_id = nil, **options)
    if tag_id
      @message_hash.merge!(filter: { is_to_all: false, tag_id: tag_id }, **options)
    else
      @message_hash.merge!(filter: { is_to_all: true }, **options)
    end
  end

  def to(*openid, **options)
    openid = openid[0] if openid.size == 1
    @message_hash.merge!(touser: openid, **options)
  end

  def template(opts = {})
    template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
    @message_hash.merge!(MsgType: 'template', Template: template_fields)
  end
    
end
