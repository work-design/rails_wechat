class Wechat::Message::Received < Wechat::Message::Base

  def initialize(app, message_body)
    @message_body = message_body
    @request = wechat_user.wechat_requests.build(wechat_app_id: app.id, type: type)
    @request.msg_type = @message_hash['MsgType']

    parse_content
  end

  def type
    if @message_hash['MsgType'] == 'event'
      EVENT[@message_hash['Event']]
    else
      MSG_TYPE[@message_hash['MsgType']]
    end
  end

  def reply
    @reply = Wechat::Message::Replied.new(
      @request,
      ToUserName: @message_hash['FromUserName'],
      FromUserName: @message_hash['ToUserName'],
      CreateTime: Time.now.to_i
    )
  end

end
