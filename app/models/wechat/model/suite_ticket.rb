module Wechat
  module Model::SuiteTicket
    extend ActiveSupport::Concern

    included do
      attribute :suiteid, :string
      attribute :to, :string
      attribute :ticket_data, :string
      attribute :agent_id, :string
      attribute :message_hash, :json
      attribute :info_type, :string
      attribute :auth_corp_id, :string
      attribute :user_id, :string

      belongs_to :suite, foreign_key: :suiteid, primary_key: :suite_id, optional: true
      belongs_to :corp_user, ->(o) { where(suite_id: o.suiteid, corp_id: o.auth_corp_id) }, foreign_key: :user_id, primary_key: :user_id, optional: true

      before_save :parsed_data
      after_save :sync_suite_ticket, if: -> { ['suite_ticket'].include?(info_type) && saved_change_to_info_type? }
      after_save_commit :sync_auth_code, if: -> { ['create_auth', 'reset_permanent_code'].include?(info_type) && saved_change_to_info_type? }
      after_create_commit :clean_last, if: -> { ['suite_ticket', 'reset_permanent_code'].include?(info_type) }
      after_create_commit :compute_corp_id!, if: -> { ['change_external_contact'].include?(info_type) }
      after_create_commit :deal_contact, if: -> { ['change_external_contact'].include?(info_type) }
    end

    def parsed_data
      content = suite.decrypt(ticket_data)
      data = Hash.from_xml(content).fetch('xml', {})

      self.info_type = data['InfoType'] || data['Event']
      self.message_hash = data

      # 同步 userid 和 corpid
      self.user_id = message_hash['UserID']
      self.auth_corp_id = message_hash['AuthCorpId']

      data
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
      r = suite.provider.api.open_corpid(to)
      self.auth_corp_id = r['open_corpid']
      self.save
    end

    def clean_last
      self.class.where(suiteid: suiteid, info_type: info_type).where.not(id: id).delete_all
    end

    def deal_contact
      if corp_user && ['add_external_contact'].include?(message_hash['ChangeType'])
        corp_user.sync_external(message_hash['ExternalUserID'])
      end
    end

  end
end
