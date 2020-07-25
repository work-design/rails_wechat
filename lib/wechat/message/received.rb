class Wechat::Message::Received < Wechat::Message::Base





  def reply
    @reply = Wechat::Message::Replied.new(
      @request,
      ToUserName: @message_hash['FromUserName'],
      FromUserName: @message_hash['ToUserName'],
      CreateTime: Time.now.to_i
    )
  end

end
