module Wechat
  module Model::ProviderTicket
    extend ActiveSupport::Concern

    included do
      attribute :timestamp, :integer
      attribute :nonce, :string
      attribute :msg_signature, :string
      attribute :suite_id, :string
      attribute :ticket_data, :string
      attribute :agent_id, :string
      attribute :message_hash, :json
      attribute :info_type, :string

      belongs_to :provider, foreign_key: :suite_id, primary_key: :suite_id, optional: true

      after_create :parsed_data, if: -> { provider.present? }
      after_save :sync_auth_code, if: -> { ['create_auth'].include?(info_type) && saved_change_to_info_type? }
      after_create_commit :clean_last
    end

    def parsed_data
      content = provider.decrypt(ticket_data)

      data = Hash.from_xml(content).fetch('xml', {})
      provider.suite_ticket_pre = provider.suite_ticket
      provider.suite_ticket = data['SuiteTicket']
      provider.save
      self.info_type = data['InfoType']
      self.message_hash = data
      self.save
      data
    end

    def sync_auth_code
      provider.auth_code = message_hash.dig('AuthCode')
      provider.auth_code_expires_at = 10.minutes.since
      provider.save
    end

    def clean_last
      ProviderTicketCleanJob.perform_later(self)
    end

  end
end
