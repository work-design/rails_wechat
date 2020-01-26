# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(params)
    @message_hash = params
  end

  def by(wechat_request)
    r = wechat_request.response
    if r.is_a? WechatReply
      r.content
    end
  end

  def to(openid_or_userid)
    update(ToUserName: openid_or_userid)
  end

  def with(wechat_reply)
    wechat_reply.to_hash
  end

  def save_to_db!
    @wecaht_app.body = @message_hash
    @wecaht_app.save!
    self
  end

end
