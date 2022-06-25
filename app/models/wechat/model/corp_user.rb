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
      belongs_to :corp, ->(o){ where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id, optional: true
      belongs_to :app, foreign_key: :corp_id, primary_key: :appid, optional: true

      belongs_to :organ, class_name: 'Org::Organ'
      has_one :member, ->(o){ where(organ_id: o.organ_id) }, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity
      has_one :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity
      has_one :user, class_name: 'Auth::User', through: :account

      has_many :maintains, through: :member
      has_many :contacts, ->(o){ where(corp_id: o.corp_id, suite_id: o.suite_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :follows, ->(o){ where(corp_id: o.corp_id) }, class_name: 'Crm::Maintain', foreign_key: :userid, primary_key: :user_id
      has_many :externals, through: :follows

      validates :identity, presence: true

      before_validation :sync_identity, if: -> { user_id_changed? }
      before_validation :init_account, if: -> { identity_changed? }
      before_validation :init_corp, if: -> { suite_id.present? && suite_id_changed? }
      after_save :auto_join_organ, if: -> { saved_change_to_identity? }
    end

    def temp_identity
      [corp_id, user_id].join('-')
    end

    def sync_identity
      self.identity = temp_identity
    end

    def init_account
      return if account
      if identity.include?('-')
        build_account(type: 'Auth::ThirdpartyAccount')
      else
        temp_account = ::Auth::Account.find_by(identity: temp_identity)
        if temp_account
          temp_account.type = 'Auth::MobileAccount'
          temp_account.identity = self.identity
          temp_account.confirmed = true
          temp_account.save
          self.account = temp_account
        else
          build_account(type: 'Auth::MobileAccount', confirmed: true)
        end
      end
    end

    def init_corp
      corp || build_corp(suite_id: suite_id)
    end

    def auto_join_organ
      return if member
      return unless corp || organ
      if organ
        temp_member = organ.members.find_by(identity: temp_identity)
        if temp_member
          temp_member.identity = self.identity
          temp_member.save
        else
          build_member(organ_id: organ.id)
          member.name = user_id
          member.save
        end
      else
        build_member(organ_id: corp.organ.id)
        member.name = user_id
        member.save
      end
    end

    def get_detail_by_suite
      return unless suite
      r = suite.api.user_detail(user_ticket)
      if r['errcode'] == 0
        self.assign_attributes r.slice('name', 'gender', 'qr_code')
        self.identity = r['mobile'] if r['mobile']
        self.avatar_url = r['avatar']
        self.save
      end
    end

    def sync_externals
      r = (corp || app).api.batch(user_id)
      list = r.fetch('external_contact_list', [])
      list.each do |item|
        contact = item.fetch('external_contact', {})
        external = externals.find_or_initialize_by(external_userid: contact['external_userid'])
        external.external_type = contact['type']
        external.assign_attributes contact.slice('name', 'position', 'avatar', 'corp_name', 'corp_full_name', 'gender', 'unionid')

        info = item.fetch('follow_info', {})
        follow = external.follows.find_or_initialize_by(userid: info['userid'])
        follow.assign_attributes info.slice('remark', 'state', 'oper_userid', 'add_way')
        follow.note = info['description']

        external.save
      end
    end

    def sync_external(external_userid)
      r = (corp || app).api.item(external_userid)
      item = r.fetch('external_contact', {})
      follow_infos = r.fetch('follow_user', [])

      external = externals.find_or_initialize_by(external_userid: item['external_userid'])
      external.external_type = item['type']
      external.assign_attributes item.slice('name', 'avatar', 'gender', 'unionid', 'position')

      follow_infos.each do |info|
        follow = external.follows.find_or_initialize_by(userid: info['userid'])
        follow.assign_attributes info.slice('remark', 'state', 'oper_userid', 'add_way')
        follow.note = info['description']
      end

      external.save
      external
    end

  end
end
