# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(request, **params)
    @request = request
    @message_hash = params.with_indifferent_access
  end

  def to(openid)
    update(ToUserName: openid)
  end

  def get_reply
    r = request.reply

    if r.respond_to? :to_wechat
      update **r.to_wechat
    else
      update(MsgType: 'text', Content: r)
    end
  end

  def to_xml
    if content_blank?
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
