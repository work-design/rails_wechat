# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(params)
    @message_hash = params
  end

  def to(openid)
    update(ToUserName: openid)
  end

  def save_to_db!
    @wecaht_app.body = @message_hash
    @wecaht_app.save!
    self
  end

end
