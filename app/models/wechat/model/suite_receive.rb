module Wechat
  module Model::SuiteReceive
    extend ActiveSupport::Concern

    included do
      attribute :suiteid, :string, index: true
      attribute :corpid, :string, index: true
      attribute :auth_corp_id, :string
      attribute :user_id, :string, index: true
      attribute :agent_id, :string
      attribute :msg_id, :string
      attribute :msg_type, :string
      attribute :event, :string
      attribute :event_key, :string
      attribute :encrypt_data, :string
      attribute :message_hash, :json
      attribute :info_type, :string

      belongs_to :provider, optional: true
      belongs_to :suite, foreign_key: :suiteid, primary_key: :suite_id, optional: true
      belongs_to :agent, ->(o){ where(corpid: o.corpid) }, foreign_key: :agent_id, primary_key: :agentid, optional: true
      belongs_to :corp, ->(o) { where(suite_id: o.suiteid) }, foreign_key: :auth_corp_id, primary_key: :corpid, optional: true
      belongs_to :corp_user, ->(o) { where(o.filter_hash) }, foreign_key: :user_id, primary_key: :userid, optional: true

      enum msg_format: {
        json: 'json',
        xml: 'xml'
      }, _default: 'xml'

      before_save :decrypt_data, if: -> { encrypt_data_changed? && encrypt_data.present? }
      after_save :sync_suite_ticket, if: -> { ['suite_ticket'].include?(info_type) && saved_change_to_info_type? }
      after_create_commit :clean_last, if: -> { ['suite_ticket', 'reset_permanent_code'].include?(info_type) }
      after_create_commit :compute_corp_id!, if: -> { ['change_external_contact'].include?(info_type) }
      after_save_commit :sync_auth_code, if: -> { ['create_auth', 'reset_permanent_code'].include?(info_type) && saved_change_to_info_type? }
      after_save_commit :deal_contact, if: -> { ['change_external_contact'].include?(info_type) && (['auth_corp_id', 'corpid'] & saved_changes.keys).present? }
    end

    def filter_hash
      if suiteid
        { suite_id: suiteid, corpid: auth_corp_id }
      else
        { corpid: corpid, suite_id: suiteid }
      end
    end

    def decrypt_data
      content = (agent || suite).decrypt(encrypt_data)

      if self.xml?
        self.message_hash = Hash.from_xml(content).fetch('xml', {})
      else
        self.message_hash = JSON.parse(content)
      end

      self.info_type = message_hash['InfoType'] || message_hash['Event']
      # 同步 userid 和 corpid
      self.user_id = message_hash['UserID'] || message_hash['FromUserName']
      case self.info_type
      when 'change_external_contact'
        self.corpid = message_hash['AuthCorpId'] || message_hash['ToUserName']
      else
        self.corpid = message_hash['ToUserName']
      end
      self.auth_corp_id = message_hash['AuthCorpId']
      self.agent_id ||= message_hash['AgentID']
      self.msg_type = message_hash['MsgType']
      self.msg_id = message_hash['MsgId']
      self.event = message_hash['Event']
      self.event_key = message_hash['EventKey']
      self.message_hash
    end

    def sync_suite_ticket
      suite.suite_ticket_pre = suite.suite_ticket
      suite.suite_ticket = message_hash['SuiteTicket']
      suite.save
    end

    # auth code expires after 10 minutes
    def sync_auth_code
      auth_code = message_hash.dig('AuthCode')
      suite.generate_corp(auth_code)
    end

    def compute_corp_id!
      return unless suite
      r = suite.provider.api.open_corpid(corpid)
      logger.debug "\e[35m  Corp id: #{r}  \e[0m"
      self.auth_corp_id ||= r['open_corpid']
      self.save
    end

    def clean_last
      self.class.where(suiteid: suiteid, info_type: info_type).where.not(id: id).delete_all
    end

    def deal_contact
      return unless corp_user
      corp_user.sync_external(message_hash['ExternalUserID'])
    end

  end
end
