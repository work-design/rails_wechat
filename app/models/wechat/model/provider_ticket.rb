module Wechat
  module Model::ProviderTicket
    extend ActiveSupport::Concern

    included do
      attribute :suite_id, :string
      attribute :ticket_data, :string
      attribute :agent_id, :string
      attribute :message_hash, :json
      attribute :info_type, :string

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true

      before_save :parsed_data
      after_save :sync_suite_ticket, if: -> { ['suite_ticket'].include?(info_type) && saved_change_to_info_type? }
      after_save :sync_auth_code, if: -> { ['create_auth'].include?(info_type) && saved_change_to_info_type? }
      after_create_commit :clean_last, if: -> { ['suite_ticket'].include?(info_type) }
    end

    def parsed_data
      content = suite.decrypt(ticket_data)
      data = Hash.from_xml(content).fetch('xml', {})

      self.info_type = data['InfoType']
      self.message_hash = data
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

    def clean_last
      ProviderTicketCleanJob.perform_later(self)
    end

  end
end
