# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(params)
    @message_hash = params
  end

  def to(openid)
    update(ToUserName: openid)
  end

  def get_reply
    r = request.reply

    if r.respond_to? :to_wechat
      update(content: r.to_wechat)
    else
      update(MsgType: 'text', Content: r)
    end
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
