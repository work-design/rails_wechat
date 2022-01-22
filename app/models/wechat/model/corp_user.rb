module Wechat
  module Model::CorpUser
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :user_id, :string
      attribute :device_id, :string
      attribute :user_ticket, :string
      attribute :ticket_expires_at, :datetime
      attribute :open_userid, :string
      attribute :open_id, :string

      belongs_to :provider, optional: true
      belongs_to :corp, foreign_key: :corp_id, primary_key: :corp_id, optional: true
    end

    def xx

    end

  end
end
