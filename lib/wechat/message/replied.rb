# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(params)
    @message_hash = params
  end

  def by(wechat_request)
    r = wechat_request.response
    if r.is_a? WechatReply

    end
  end

  def to(openid_or_userid)
    update(ToUserName: openid_or_userid)
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




end
