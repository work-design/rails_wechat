class Wechat::Message::Received < Wechat::Message::Base

  # see: https://mp.weixin.qq.com/wiki?id=mp1421140453
  MSG_TYPE = [
    'text', 'image', 'voice', 'video', 'shortvideo', 'location', 'link', 'event' # 消息类型
  ].freeze
  # see: https://mp.weixin.qq.com/wiki?id=mp1421140454
  # see: https://work.weixin.qq.com/api/doc#90000/90135/90240
  EVENT = [
    'subscribe', 'unsubscribe', 'LOCATION', # 公众号与企业微信通用
    'CLICK', 'VIEW', 'SCAN',  # 公众号使用
    'click', 'view',  # 企业微信使用
    'scancode_push', 'scancode_waitmsg', 'pic_sysphoto', 'pic_photo_or_album', 'pic_weixin', 'location_select', 'enter_agent', 'batch_job_result'  # 企业微信使用
  ].freeze

  def self.from_controller(controller)
    app = controller.instance_variable_get(:@wechat_app)
    new(app, controller.request.raw_post, controller.class.configs)
  end

  attr_reader :app, :rules
  def initialize(app, message_body, rules)
    @app = app
    @message_body = message_body
    @rules = rules
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
      content, @we_app_id = Wechat::Cipher.unpack(r)

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

  def parse_content
    case @message_hash['MsgType']
    when 'text'
      @content = @message_hash['Content']
      @with = @content
    when 'image', 'voice', 'video', 'shortvideo'
      @content = @message_hash.slice('MediaId')
    when 'location'
      @content = @message_hash.slice('Location_X', 'Location_Y', 'Scale', 'Label')
    when 'event'
      case @message_hash['Event']
      when 'LOCATION'
        @content = @message_hash.slice('Event', 'Latitude', 'Longitude', 'Precision')
      else
        @content = @message_hash.slice('Event', 'EventKey', 'Ticket')
        @with = @message_hash['EventKey']
      end
    else
      warn "Don't know how to parse message as #{@message_hash['MsgType']}", uplevel: 1
    end
  end

  def reply
    Wechat::Message::Replied.new(
      ToUserName: @message_hash['FromUserName'],
      FromUserName: @message_hash['ToUserName'],
      CreateTime: Time.now.to_i
    )
  end

  def response
    filtered = @rules.find do |rule|
      next unless rule[:msg_type].to_s == @message_hash['MsgType']

      if rule[:msg_type] == :event
        next unless rule[:event].underscore == @message_hash['Event'].underscore
      end

      if rule[:with]
        @with.match? rule[:with]
      else
        true
      end
    end

    if filtered
      filtered[:proc].call(self, @content)
    else
      {}
    end
  end

end
