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

      belongs_to :provider, foreign_key: :suite_id, primary_key: :suite_id, optional: true

      after_create_commit :parsed_data, if: -> { provider.present? }
      after_create_commit :clean_last
    end

    def parsed_data
      content = provider.decrypt(ticket_data)

      data = Hash.from_xml(content).fetch('xml', {})
      provider.suite_ticket_pre = provider.suite_ticket
      provider.suite_ticket = data['SuiteTicket']
      data
    end

    def clean_last
      ProviderTicketCleanJob.perform_later(self)
    end

  end
end
