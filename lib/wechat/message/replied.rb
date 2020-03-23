# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(params)
    @message_hash = params
  end

  def to(openid)
    update(ToUserName: openid)
  end

  def to_xml
    if @message_hash[:Content].blank?
      'success'
    else
      super
    end
  end

  def save!
    @wecaht_request_reply.save!
    self
  end

end
