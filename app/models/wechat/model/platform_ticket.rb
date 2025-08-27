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
      attribute :message_hash, :json
      attribute :info_type, :string

      belongs_to :platform, foreign_key: :appid, primary_key: :appid, optional: true

      before_save :parsed_data, if: -> { ticket_data_changed? }
      after_create_commit :update_platform_ticket, if: -> { platform.present? }
      after_create_commit :clean_last_later, if: -> { ['component_verify_ticket'].include?(info_type) }
      after_create_commit :disable_app, if: -> { ['unauthorized'].include?(info_type) }
    end

    def disable_app
      app = App.find_by appid: message_hash['AuthorizerAppid']
      app.enabled = false
      app.save
    end

    def parsed_data
      content = platform.decrypt(ticket_data)
      data = Hash.from_xml(content).fetch('xml', {})
      self.message_hash = data
      self.info_type = data['InfoType']
    end

    def update_platform_ticket
      r = message_hash['ComponentVerifyTicket']
      return unless r.present?
      platform.update verify_ticket: r
    end

    def clean_last_later
      PlatformTicketCleanJob.perform_later(self)
    end

    def clean_last
      self.class.where(appid: appid, info_type: info_type).where.not(id: id).delete_all
    end

  end
end
