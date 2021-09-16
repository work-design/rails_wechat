module Wechat
  module Model::Ticket
    extend ActiveSupport::Concern

    included do
      attribute :signature, :string
      attribute :timestamp, :integer
      attribute :nonce, :string
      attribute :msg_signature, :string
      attribute :appid, :string
      attribute :ticket_data, :string

      belongs_to :platform, foreign_key: :appid, primary_key: :appid, optional: true

      after_create_commit :parsed_data, if: -> { platform.present? }
      after_create_commit :clean_last
    end

    def parsed_data
      r = Wechat::Cipher.decrypt(Base64.decode64(ticket_data), platform.encoding_aes_key)
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
