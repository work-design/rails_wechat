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

      belongs_to :provider, optional: true
    end

  end
end
