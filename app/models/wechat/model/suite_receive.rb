module Wechat
  module Model::SuiteReceive
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
      belongs_to :suite, optional: true

      enum msg_format: {
        json: 'json',
        xml: 'xml'
      }, _default: 'xml'

      before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
      before_save :parse_message_hash, if: -> { message_hash_changed? && message_hash.present? }
    end

    def decrypt_data
      aes_key = suite.encoding_aes_key
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

  end
end
