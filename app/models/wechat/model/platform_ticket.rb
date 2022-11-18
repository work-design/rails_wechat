module Wechat
  module Model::PlatformTicket
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
      content = platform.decrypt(ticket_data)
      data = Hash.from_xml(content).fetch('xml', {})

      platform.update(verify_ticket: data['ComponentVerifyTicket'])
      data
    end

    def clean_last
      PlatformTicketCleanJob.perform_later(self)
    end

  end
end
