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
  # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_event_pushes.html
  # https://work.weixin.qq.com/api/doc/90000/90135/90240
  EVENT = {
    'subscribe' => 'SubscribeRequest',
    'unsubscribe' => 'UnsubscribeRequest',
    'LOCATION' => 'WechatRequestLocation', # 公众号与企业微信通用
    'CLICK' => 'WechatRequestClick',
    'VIEW' => 'ViewRequest',
    'SCAN' => 'ScanRequest',
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
    attribute :appid, :string, index: true
    attribute :open_id, :string, index: true
    attribute :msg_id, :string
    attribute :msg_type, :string
    attribute :content, :string
    attribute :encrypt_data, :string
    attribute :message_hash, :json

    belongs_to :wechat_platform, optional: true
    belongs_to :wechat_request, optional: true
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

    before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
    before_save :parse_message_hash, if: -> { message_hash_changed? && message_hash.present? }
    before_save :init_wechat_user, if: -> { open_id_changed? && open_id.present? }
    after_create_commit :parse_content
    after_create_commit :check_wechat_app
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

  def compute_type
    if msg_type == 'event'
      EVENT[message_hash['Event']]
    else
      MSG_TYPE[msg_type]
    end
  end

  def parse_content
    wechat_request || build_wechat_request(type: compute_type)
    wechat_request.appid = appid
    wechat_request.open_id = open_id
    wechat_request.msg_type = msg_type
    wechat_request.raw_body = message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')

    case msg_type
    when 'text'
      wechat_request.body = message_hash['Content']
    when 'event'
      wechat_request.event = message_hash['Event']
      wechat_request.event_key = message_hash['EventKey']
      wechat_request.body = message_hash.dig('ScanCodeInfo', 'ScanResult') || message_hash['EventKey']
    when 'image'
      wechat_request.body = message_hash['PicUrl']
    when 'voice'
      wechat_request.body = message_hash['Recognition'].presence || message_hash['MediaId']
    when 'video', 'shortvideo'
      wechat_request.body = message_hash['MediaId']
    when 'location'
      wechat_request.body = "#{message_hash['Location_X']}:#{message_hash['Location_Y']}"
    when 'link'
      wechat_request.body = message_hash['Url']
    else
      warn "Don't know how to parse message as #{message_hash['MsgType']}", uplevel: 1
    end

    self.save  # will auto save wechat request
  end

  def check_wechat_app
    wechat_app.update user_name: message_hash['ToUserName'] if wechat_app
  end

  def reply
    wechat_request.reply
    wechat_request.save
    wechat_request
  end

end
