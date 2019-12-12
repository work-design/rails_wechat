# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Batch_Sends_and_Originality_Checks.html
class Wechat::Message::Mass::Public < Wechat::Message::Mass
  MSG_TYPE = {
    mpnews: 'media_id',
    voice: 'media_id',
    image: 'media_id',
    mpvideo: 'media_id',
    text: 'content',
    wxcard: 'card_id'
  }.freeze
  
  def to_mass(tag_id = nil, **options)
    if tag_id
      @message_hash.merge!(filter: { is_to_all: false, tag_id: tag_id }, **options)
    else
      @message_hash.merge!(filter: { is_to_all: true }, **options)
    end
    @send_to = 'message/mass/sendall'
    self
  end
  
  def do_send
    api.post @send_to, @message_hash
  end

  def to(*openid, **options)
    raise 'must send to more than 2 uses!' if openid.size < 2
    @message_hash.merge!(touser: openid, **options)
    @send_to = 'message/mass/send'
    self
  end

  def content(msgtype, body)
    @message_hash[msgtype] = {
      MSG_TYPE[msgtype.to_sym] => body
    }
  end
  
end
