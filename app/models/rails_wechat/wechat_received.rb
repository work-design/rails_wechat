module RailsWechat::WechatReceived
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
  extend ActiveSupport::Concern

  included do
    attribute :appid, :string
    attribute :open_id, :string
    attribute :msg_id, :string
    attribute :msg_type, :string
    attribute :content, :string
    attribute :encrypt_data, :string
    attribute :message_hash, :json

    belongs_to :wechat_platform, optional: true
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

    before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
    before_save :parse_message_hash, if: -> { message_hash_changed? && message_hash.present? }
    before_save :init_wechat_user, if: -> { open_id_changed? && open_id.present? }
  end

  def decrypt_data
    aes_key = wechat_platform ? wechat_platform.encoding_aes_key : wechat_app.encoding_aes_key
    r = Wechat::Cipher.decrypt(Base64.decode64(encrypt_data), aes_key)
    content, _ = Wechat::Cipher.unpack(r)

    self.message_hash = Hash.from_xml(content).fetch('xml', {})
  end

  def parse_message_hash
    self.open_id = message_hash['FromUserName']
    self.msg_type = message_hash['MsgType']
    self.msg_id = message_hash['MsgId']
  end

  def init_wechat_user
    wechat_user || build_wechat_user
    wechat_user.app_id = appid
    wechat_user.save
  end

  def request_type
    if message_hash['MsgType'] == 'event'
      EVENT[message_hash['Event']]
    else
      MSG_TYPE[message_hash['MsgType']]
    end
  end

  def parse_content
    @request.raw_body = message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')

    case msg_type
    when 'text'
      @request.body = message_hash['Content']
    when 'image', 'voice', 'video', 'shortvideo', 'location', 'event'
      @request.event = message_hash['Event']
      @request.body = message_hash['EventKey']
    else
      warn "Don't know how to parse message as #{message_hash['MsgType']}", uplevel: 1
    end
  end

  def to_request
    @wechat_request = wechat_app.wechat_requests.build(wechat_user_id: app.id, type: type)
    @wechat_request.msg_type = message_hash['MsgType']
    @wechat_request.save
  end

end
