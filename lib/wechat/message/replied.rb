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

  def save_to_db!
    model = WechatReply.new
    model.body = @message_hash
    model.save!
    self
  end

end
