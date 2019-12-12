# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base
  
  def initialize(params)
    @message_hash = params
  end
  
  def to(openid_or_userid)
    @message_hash.merge!(ToUserName: openid_or_userid)
  end

  # 公众号消息类型
  # see: https://mp.weixin.qq.com/wiki?id=mp1421140543
  def text(content)
    @message_hash.merge!(MsgType: 'text', Content: content)
  end

  def image(media_id)
    @message_hash.merge!(MsgType: 'image', Image: { MediaId: media_id })
  end

  def voice(media_id)
    @message_hash.merge!(MsgType: 'voice', Voice: { MediaId: media_id })
  end

  def video(media_id, **options)
    options.slice!(:title, :description)
    options.transform_keys! { |k| k.to_s.camelize.to_sym }

    @message_hash.merge!(
      MsgType: 'video',
      Video: { MediaId: media_id }.merge!(options)
    )
  end
  
  def music(thumb_media_id, **options)
    r = options.slice!(:title, :description, :HQ_music_url)
    options.transform_keys! { |k| k.to_s.camelize.to_sym }
    options.merge! MusicURL: r[:music_url] if r[:music_ul]
    @message_hash.merge!(
      MsgType: 'music',
      Music: { ThumbMediaId: thumb_media_id }.merge!(options)
    )
  end

  def news(collection, limit = 8)
    items = collection.take(limit).map do |item|
      item.slice(:title, :description, :pic_url, :url).transform_keys! { |k| k.to_s.camelize.to_sym }
    end
    
    @message_hash.merge!(MsgType: 'news', ArticleCount: items.count, Articles: items)
  end
  
end
