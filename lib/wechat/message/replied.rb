# frozen_string_literal: true

module Wechat::Message
  class Replied < Base
  
    def to(openid_or_userid)
      update(ToUserName: openid_or_userid)
    end
    
    def initialize(params)
      @message_hash = params
    end
  
    # 公众号消息类型
    # see: https://mp.weixin.qq.com/wiki?id=mp1421140543
    def text(content)
      update(MsgType: 'text', Content: content)
    end

    def image(media_id)
      update(MsgType: 'image', Image: { MediaId: media_id })
    end

    def voice(media_id)
      update(MsgType: 'voice', Voice: { MediaId: media_id })
    end

    def video(media_id, **options)
      options.slice!(:title, :description)
      options.transform_keys! { |k| k.to_s.camelize.to_sym }

      update(
        MsgType: 'video',
        Video: { MediaId: media_id }.merge!(options)
      )
    end
    
    def music(thumb_media_id, **options)
      r = options.slice!(:title, :description, :HQ_music_url)
      options.transform_keys! { |k| k.to_s.camelize.to_sym }
      options.merge! MusicURL: r[:music_url] if r[:music_ul]
      update(
        MsgType: 'music',
        Music: { ThumbMediaId: thumb_media_id }.merge!(options)
      )
    end

    def news(collection, limit = 8)
      items = collection.take(limit).map do |item|
        item.slice(:title, :description, :pic_url, :url).transform_keys! { |k| k.to_s.camelize.to_sym }
      end
      
      update(MsgType: 'news', ArticleCount: items.count, Articles: items)
    end
    
  end
end
