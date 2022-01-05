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

      #after_create_commit :parsed_data, if: -> { provider.present? }
      #after_create_commit :clean_last
    end

    def parsed_data
      r = Wechat::Cipher.decrypt(Base64.decode64(ticket_data), provider.encoding_aes_key)
      content, _ = Wechat::Cipher.unpack(r)

      data = Hash.from_xml(content).fetch('xml', {})
      platform.update(verify_ticket: data['ComponentVerifyTicket'])
      data
    end

    def clean_last
      TicketCleanJob.perform_later(self)
    end

  end
end
