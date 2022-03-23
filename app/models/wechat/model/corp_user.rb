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
      attribute :suite_id, :string

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true
      belongs_to :corp, ->(o){ where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id

      has_one :member, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity
      has_one :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity
      has_one :user, through: :account

      has_many :contacts, ->(o){ where(corp_id: o.corp_id, suite_id: o.suite_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :externals, ->(o){ where(corp_id: o.corp_id) }, foreign_key: :userid, primary_key: :user_id

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
      corp || build_corp(suite_id: suite_id)
    end

    def init_account
      account || build_account(type: 'Auth::ThirdpartyAccount')
    end

    def auto_join_organ
      member || build_member(organ_id: corp.organ.id)
      member.name = user_id
      member.save
    end

    def get_detail
      r = suite.api.user_detail(user_ticket)
      if r['errcode'] == 0
        self.assign_attributes r.slice('name', 'gender')
        self.avatar_url = r['avatar']
        self.save
      end
    end

    def sync_externals
      r = corp.api.batch(user_id)
      list = r.fetch('external_contact_list', [])
      list.each do |item|
        contact = item.fetch('external_contact', {})
        external = externals.find_or_initialize_by(external_userid: contact['external_userid'])
        external.external_type = contact['type']
        external.assign_attributes contact.slice('name', 'position', 'avatar', 'corp_name', 'corp_full_name', 'gender', 'unionid')

        info = item.fetch('follow_info', {})
        follow = external.follows.find_or_initialize_by(userid: info['userid'])
        follow.assign_attributes info.slice('remark', 'description', 'state', 'oper_userid', 'add_way')

        external.save
      end
    end

    def sync_external(external_userid)
      r = corp.api.item(external_userid)
      item = r.fetch('external_contact', {})
      follow_infos = r.fetch('follow_user', [])

      external = externals.find_or_initialize_by(external_userid: item['external_userid'])
      external.external_type = item['type']
      external.assign_attributes item.slice('name', 'avatar', 'gender', 'unionid', 'position')

      follow_infos.each do |info|
        follow = external.follows.find_or_initialize_by(userid: info['userid'])
        follow.assign_attributes info.slice('remark', 'description', 'state', 'oper_userid', 'add_way')
      end

      external.save
      r
    end

  end
end
