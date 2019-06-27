module Wechat::Message
  class Push::Public < Push
    # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1481187827_i0l21
    MSG_TYPE = [
      'mpnews', 'voice', 'image', 'mpvideo',  # media_id
      'text',  # content
      'wxcard'  # card_id
    ].freeze


    # see: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1481187827_i0l21
    def to_mass(tag_id = nil, **options)
      if tag_id
        update(filter: { is_to_all: false, tag_id: tag_id }, **options)
      else
        update(filter: { is_to_all: true }, **options)
      end
    end

    def to(*openid, **options)
      update(touser: openid, **options)
    end
    
  end
end
