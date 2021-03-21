module Wechat
  module Model::Received
    # see: https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_standard_messages.html
    MSG_TYPE = {
      'text' => 'Wechat::TextRequest',
      'image' => 'Wechat::RequestImage',
      'voice' => 'Wechat::RequestVoice',
      'video' => 'Wechat::RequestVideo',
      'shortvideo' => 'Wechat::RequestShortVideo',
      'location' => 'Wechat::RequestLocation',
      'link' => 'Wechat::RequestLink',
      'event' => 'Wechat::RequestEvent'
    }.freeze
    # https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Receiving_event_pushes.html
    # https://work.weixin.qq.com/api/doc/90000/90135/90240
    EVENT = {
      'subscribe' => 'Wechat::SubscribeRequest',
      'unsubscribe' => 'Wechat::UnsubscribeRequest',
      'LOCATION' => 'Wechat::RequestLocation', # 公众号与企业微信通用
      'CLICK' => 'Wechat::RequestClick',
      'VIEW' => 'Wechat::ViewRequest',
      'SCAN' => 'Wechat::ScanRequest',
      'click' => 'Wechat::Request',
      'view' => 'Wechat::Request',  # 企业微信使用
      'scancode_push' => 'Wechat::Request',
      'scancode_waitmsg' => 'Wechat::Request',
      'pic_sysphoto' => 'Wechat::Request',
      'pic_photo_or_album' => 'Wechat::Request',
      'pic_weixin' => 'Wechat::Request',
      'location_select' => 'Wechat::Request',
      'enter_agent' => 'Wechat::Request',
      'batch_job_result' => 'Wechat::Request'  # 企业微信使用
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

      belongs_to :platform, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true

      has_one :request

      before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
      before_save :parse_message_hash, if: -> { message_hash_changed? && message_hash.present? }
      before_save :init_wechat_user, if: -> { open_id_changed? && open_id.present? }
      after_create :parse_content
      after_create_commit :check_wechat_app
    end

    def decrypt_data
      aes_key = platform ? platform.encoding_aes_key : app.encoding_aes_key
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
      build_request(type: compute_type)
      request.appid = appid
      request.open_id = open_id
      request.msg_type = msg_type
      request.raw_body = message_hash.except('ToUserName', 'FromUserName', 'CreateTime', 'MsgType')

      case msg_type
      when 'text'
        request.body = message_hash['Content']
      when 'event'
        request.event = message_hash['Event']
        request.event_key = message_hash['EventKey'] || message_hash.dig('ScanCodeInfo', 'ScanResult')
        if request.event == 'subscribe'
          request.body = request.event_key.delete_prefix('qrscene_')
        else
          request.body = request.event_key
        end
      when 'image'
        request.body = message_hash['PicUrl']
      when 'voice'
        request.body = message_hash['Recognition'].presence || message_hash['MediaId']
      when 'video', 'shortvideo'
        request.body = message_hash['MediaId']
      when 'location'
        request.body = "#{message_hash['Location_X']}:#{message_hash['Location_Y']}"
      when 'link'
        request.body = message_hash['Url']
      else
        warn "Don't know how to parse message as #{message_hash['MsgType']}", uplevel: 1
      end

      self.save  # will auto save wechat request
    end

    def check_wechat_app
      app.update user_name: message_hash['ToUserName'] if app
    end

    def reply
      request.reply
      request.save
      request
    end

  end
end
