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
      attribute :identity, :string

      belongs_to :provider, optional: true
      belongs_to :corp, foreign_key: :corp_id, primary_key: :corp_id, optional: true

      has_one :member, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity
      has_one :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity

      validates :identity, presence: true

      before_validation :sync_identity, -> { user_id_changed? }
      before_create :init_account
    end

    def sync_identity
      self.identity = [corp_id, user_id].join('_')
    end

    def init_account
      account || build_account(type: 'Auth::ThirdpartyAccount')
    end

    def auto_join_organ
      member = members.find_by(organ_id: user_tag.member_inviter.organ_id) || members.build(organ_id: user_tag.member_inviter.organ_id, state: 'pending_trial')
      member.save
    end

  end
end
