module Wechat
  module Model::Receive
    # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_standard_messages.html
    MSG_TYPE = {
      'text' => 'Wechat::TextRequest',
      'image' => 'Wechat::ImageRequest',
      'voice' => 'Wechat::VoiceRequest',
      'video' => 'Wechat::VideoRequest',
      'shortvideo' => 'Wechat::ShortVideoRequest',
      'location' => 'Wechat::LocationRequest',
      'link' => 'Wechat::LinkRequest',
      'event' => 'Wechat::EventRequest'
    }.freeze
    # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_event_pushes.html
    # https://work.weixin.qq.com/api/doc/90000/90135/90240
    EVENT = {
      'subscribe' => 'Wechat::SubscribeRequest',
      'unsubscribe' => 'Wechat::UnsubscribeRequest',
      'LOCATION' => 'Wechat::LocationRequest', # 公众号与企业微信通用
      'CLICK' => 'Wechat::ClickRequest',
      'VIEW' => 'Wechat::ViewRequest',
      'view_miniprogram' => 'Wechat::ViewRequest',
      'SCAN' => 'Wechat::ScanRequest',
      'click' => 'Wechat::Request',
      'view' => 'Wechat::Request',  # 企业微信使用
      'scancode_push' => 'Wechat::ScancodePushRequest',
      'scancode_waitmsg' => 'Wechat::Request',
      'pic_sysphoto' => 'Wechat::Request',
      'pic_photo_or_album' => 'Wechat::Request',
      'pic_weixin' => 'Wechat::Request',
      'location_select' => 'Wechat::Request',
      'enter_agent' => 'Wechat::Request',
      'batch_job_result' => 'Wechat::Request',  # 企业微信使用
      'subscribe_msg_popup_event' => 'Wechat::MsgRequest',  # 小程序订阅消息
      'change_external_contact' => 'Wechat::ExternalRequest'
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
      attribute :info_type, :string

      belongs_to :platform, optional: true
      belongs_to :app, ->(o){ where(platform_id: o.platform_id) }, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

      enum msg_format: {
        json: 'json',
        xml: 'xml'
      }, _default: 'xml'

      has_one :request

      before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
      before_create :parse_content
      after_create_commit :check_app
    end

    def app_name
      app.name
    end

    def decrypt_data
      content = (platform || app).decrypt(encrypt_data)

      if self.xml?
        self.message_hash = Hash.from_xml(content).fetch('xml', {})
      else
        self.message_hash = JSON.parse(content)
      end
      self.info_type = message_hash['Event']
      self.open_id = message_hash['FromUserName']
      self.msg_type = message_hash['MsgType']
      self.msg_id = message_hash['MsgId']
      self.message_hash
    end

    def compute_type
      if msg_type == 'event'
        EVENT[message_hash['Event']] || 'Wechat::Request'
      else
        MSG_TYPE[msg_type]
      end
    end

    def parse_content
      request || build_request(type: compute_type)
      request.appid = appid
      request.open_id = open_id
      request.msg_type = msg_type
      request.raw_body = message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')
    end

    def check_app
      return unless app
      app.user_name = message_hash['ToUserName']
      if ['weapp_audit_success'].include?(info_type)
        app.audit_status = 'success'
      elsif ['weapp_audit_fail'].include?(info_type)
        app.audit_status = 'rejected'
      end
      app.save
    end

  end
end
