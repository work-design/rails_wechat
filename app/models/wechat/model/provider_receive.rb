module Wechat
  module Model::ProviderReceive
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
      'subscribe_msg_popup_event' => 'Wechat::MsgRequest'  # 小程序订阅消息
    }.freeze
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string, index: true
      attribute :user_id, :string, index: true
      attribute :agent_id, :string
      attribute :msg_id, :string
      attribute :msg_type, :string
      attribute :event, :string
      attribute :event_key, :string
      attribute :content, :string
      attribute :encrypt_data, :string
      attribute :message_hash, :json

      belongs_to :provider, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

      enum msg_format: {
        json: 'json',
        xml: 'xml'
      }, _default: 'xml'

      before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
      before_save :parse_message_hash, if: -> { message_hash_changed? && message_hash.present? }
      #after_create :parse_content
      #after_create_commit :check_app
    end

    def decrypt_data
      aes_key = provider.encoding_aes_key
      r = Wechat::Cipher.decrypt(Base64.decode64(encrypt_data), aes_key)
      content, _ = Wechat::Cipher.unpack(r)

      if self.xml?
        self.message_hash = Hash.from_xml(content).fetch('xml', {})
      else
        self.message_hash = JSON.parse(content)
      end
    end

    def parse_message_hash
      self.corp_id = message_hash['ToUserName']
      self.user_id = message_hash['FromUserName']
      self.msg_type = message_hash['MsgType']
      self.msg_id = message_hash['MsgId']
      self.agent_id = message_hash['AgentID']
      self.event = message_hash['Event']
      self.event_key = message_hash['EventKey']
    end

    def compute_type
      if msg_type == 'event'
        EVENT[message_hash['Event']]
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
      request.generate_wechat_user  # Should before get reply

      self.save  # will auto save wechat request
    end

    def check_app
      app.update user_name: message_hash['ToUserName'] if app
    end

  end
end