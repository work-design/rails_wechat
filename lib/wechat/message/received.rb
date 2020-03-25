class Wechat::Message::Received < Wechat::Message::Base
  # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_standard_messages.html
  MSG_TYPE = {
    'text' => 'TextRequest',
    'image' => 'WechatRequestImage',
    'voice' => 'WechatRequestVoice',
    'video' => 'WechatRequestVideo',
    'shortvideo' => 'WechatRequestShortVideo',
    'location' => 'WechatRequestLocation',
    'link' => 'WechatRequestLink',
    'event' => 'WechatRequestEvent'
  }.freeze
  # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_event_pushes.html
  # see: https://work.weixin.qq.com/api/doc/90000/90135/90240
  EVENT = {
    'subscribe' => 'SubscribeRequest',
    'unsubscribe' => 'UnsubscribeRequest',
    'LOCATION' => 'WechatRequestLocation', # 公众号与企业微信通用
    'CLICK' => 'WechatRequest',
    'VIEW' => 'WechatRequest',
    'SCAN' => 'WechatRequest',
    'click' => 'WechatRequest',
    'view' => 'WechatRequest',  # 企业微信使用
    'scancode_push' => 'WechatRequest',
    'scancode_waitmsg' => 'WechatRequest',
    'pic_sysphoto' => 'WechatRequest',
    'pic_photo_or_album' => 'WechatRequest',
    'pic_weixin' => 'WechatRequest',
    'location_select' => 'WechatRequest',
    'enter_agent' => 'WechatRequest',
    'batch_job_result' => 'WechatRequest'  # 企业微信使用
  }.freeze

  def initialize(app, message_body)
    @app = app
    @api = @app.api
    @message_body = message_body

    post_xml

    @request = wechat_user.wechat_requests.build(wechat_app_id: app.id, type: type)
    @request.msg_type = @message_hash['MsgType']

    parse_content
    save
  end

  def post_xml
    data = Hash.from_xml(@message_body).fetch('xml', {})
    encrypt_data = data.fetch('Encrypt', nil)

    if encrypt_data.present?
      r = Base64.decode64(encrypt_data)
      r = Wechat::Cipher.decrypt(r, @app.encoding_aes_key)
      content, app_id = Wechat::Cipher.unpack(r)

      data = Hash.from_xml(content).fetch('xml', {})
    end

    @message_hash = data.with_indifferent_access
  end

  def wechat_user
    return @wechat_user if defined? @wechat_user
    @wechat_user = WechatUser.find_or_initialize_by(uid: @message_hash[:FromUserName])
    @wechat_user.app_id = app.appid
    @wechat_user.save
    @wechat_user
  end

  def type
    if @message_hash['MsgType'] == 'event'
      EVENT[@message_hash['Event']]
    else
      MSG_TYPE[@message_hash['MsgType']]
    end
  end

  def parse_content
    case @message_hash['MsgType']
    when 'text'
      @request.body = @message_hash['Content']
    when 'image', 'voice', 'video', 'shortvideo', 'location', 'event'
      @request.raw_body = @message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')
      @request.body = @message_hash['EventKey']
    else
      warn "Don't know how to parse message as #{@message_hash['MsgType']}", uplevel: 1
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

  def save
    @request.save
  end

end
