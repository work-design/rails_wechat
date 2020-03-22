class Wechat::Message::Received < Wechat::Message::Base
  # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_standard_messages.html
  MSG_TYPE = {
    'text' => 'WechatRequestText',
    'image' => 'WechatRequestImage',
    'voice' => 'WechatRequestVoice',
    'video' => 'WechatRequestVideo',
    'shortvideo' => 'WechatRequestShortVideo',
    'location' => 'WechatRequestLocation',
    'link' => 'WechatRequestLink',
    'event' => 'WechatRequestEvent'
  }
  # see: https://mp.weixin.qq.com/wiki?id=mp1421140454
  # see: https://work.weixin.qq.com/api/doc#90000/90135/90240
  EVENT = [
    'subscribe', 'unsubscribe', 'LOCATION', # 公众号与企业微信通用
    'CLICK', 'VIEW', 'SCAN',  # 公众号使用
    'click', 'view',  # 企业微信使用
    'scancode_push', 'scancode_waitmsg', 'pic_sysphoto', 'pic_photo_or_album', 'pic_weixin', 'location_select', 'enter_agent', 'batch_job_result'  # 企业微信使用
  ].freeze

  attr_reader :app, :content
  def initialize(app, message_body)
    @app = app
    @message_body = message_body
    @content = nil
    @api = @app.api

    post_xml
    parse_content
  end

  def post_xml
    data = Hash.from_xml(@message_body).fetch('xml', {})
    encrypt_data = data.fetch('Encrypt', nil)

    if encrypt_data.present?
      r = Base64.decode64(encrypt_data)
      r = Wechat::Cipher.decrypt(r, @app.encoding_aes_key)
      content, _ = Wechat::Cipher.unpack(r)

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
    MSG_TYPE[@message_hash['MsgType']]
  end

  def parse_content
    case @message_hash['MsgType']
    when 'text'
      @content = @message_hash['Content']
      @with = @content
    when 'image', 'voice', 'video', 'shortvideo', 'location', 'event'
      @content = @message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')
      @with = @message_hash['EventKey']
    else
      warn "Don't know how to parse message as #{@message_hash['MsgType']}", uplevel: 1
    end
  end

  def reply
    @reply = Wechat::Message::Replied.new(
      ToUserName: @message_hash['FromUserName'],
      FromUserName: @message_hash['ToUserName'],
      CreateTime: Time.now.to_i
    )
    wechat_request = wechat_user.wechat_requests.create(wechat_app_id: app.id, body: content, type: type)
    r = wechat_request.response

    if r.respond_to? :to_wechat
      @reply.update(content: r.to_wechat)
    else
      @reply.update(MsgType: 'text', Content: r)
    end

    @reply
  end

end
