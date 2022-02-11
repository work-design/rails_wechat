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
      attribute :name, :string
      attribute :gender, :string
      attribute :avatar_url, :string
      attribute :qr_code, :string
      attribute :department, :integer, array: []

      belongs_to :provider, optional: true
      belongs_to :corp, foreign_key: :corp_id, primary_key: :corp_id

      has_one :member, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity
      has_one :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity
      has_one :user, through: :account

      validates :identity, presence: true

      before_validation :sync_identity, -> { user_id_changed? }
      before_validation :init_corp
      before_create :init_account
      after_save :auto_join_organ, if: -> { saved_change_to_identity? }
    end

    def sync_identity
      self.identity = [corp_id, user_id].join('_')
    end

    def init_corp
      corp || build_corp(provider_id: provider_id)
    end

    def init_account
      account || build_account(type: 'Auth::ThirdpartyAccount')
    end

    def auto_join_organ
      member || build_member(organ_id: corp.organ_id)
      member.save
    end

    def get_detail
      r = provider.api.user_detail(user_ticket)
      if r['errcode'] == 0
        self.assign_attributes r.slice('name', 'gender')
        self.avatar_url = r['avatar']
        self.save
      end
    end

  end
end
