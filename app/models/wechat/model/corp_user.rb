module Wechat
  module Model::CorpUser
    GENDER = {
      0 => 'unknown',
      1 => 'male',
      2 => 'female'
    }
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :suite_id, :string, index: true
      attribute :user_id, :string
      attribute :device_id, :string
      attribute :user_ticket, :string
      attribute :ticket_expires_at, :datetime
      attribute :open_userid, :string
      attribute :open_id, :string
      attribute :identity, :string
      attribute :mobile, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :qr_code, :string
      attribute :department, :integer, array: []
      attribute :follows_count, :integer, default: 0

      enum gender: {
        male: '1',
        female: '2',
        unknown: '0'
      }

      belongs_to :member, ->(o) { where(organ_id: o.organ&.id) }, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity, optional: true
      belongs_to :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity, optional: true
      has_one :user, class_name: 'Auth::User', through: :account
      has_many :authorized_tokens, ->(o) { where(suite_id: o.suite_id) }, class_name: 'Auth::AuthorizedToken', primary_key: :identity, foreign_key: :identity, dependent: :delete_all

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true
      belongs_to :corp, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corp_id, primary_key: :corp_id, optional: true
      belongs_to :app, foreign_key: :corp_id, primary_key: :appid, optional: true

      has_many :contacts, ->(o) { where(corp_id: o.corp_id, suite_id: o.suite_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :maintains, through: :member
      has_many :clients, through: :maintains

      validates :identity, presence: true

      after_initialize :sync_identity, if: -> { new_record? && user_id.present? }
      before_validation :sync_identity, if: -> { user_id_changed? }
      before_validation :init_account, if: -> { identity_changed? }
      before_validation :init_corp, if: -> { suite_id.present? && suite_id_changed? }
      after_save :auto_join_organ, if: -> { saved_change_to_identity? }
      after_create_commit :sync_externals_later
    end

    def sync_identity
      self.identity = [corp_id, user_id].join('-')
    end

    def init_account
      return if account
      build_account(type: 'Auth::ThirdpartyAccount', confirmed: true)
    end

    def mig
      mobile_account = ::Auth::MobileAccount.find_by(identity: mobile)
      if mobile_account
        temp_account.confirmed = true
        temp_account.save
      end
    end

    def init_corp
      corp || build_corp(suite_id: suite_id)
    end

    def organ
      corp.organ
    end

    def auto_join_organ
      return if member
      return unless organ

      temp_member = organ.members.find_or_initialize_by(corp_userid: user_id)
      temp_member.identity = mobile
      temp_member.save
    end

    def get_detail_by_suite
      return unless suite
      r = suite.api.user_detail(user_ticket)
      logger.debug "\e[35m  user_detail: #{detail}  \e[0m"
      if r['errcode'] == 0
        self.assign_attributes r.slice('name', 'gender', 'qr_code', 'mobile', 'open_userid')
        self.avatar_url = r['avatar']
        self.save
      end
    end

    def sync_externals_later
      CorpSyncExternalsJob.perform_later(self)
    end

    def sync_externals(**options)
      r = (corp || app).api.batch(user_id, **options)
      return unless r['errcode'] == 0

      list = r.fetch('external_contact_list', [])
      fs = list.map do |item|
        contact = item.fetch('external_contact', {})
        external = init_external(contact)

        info = item.fetch('follow_info', {})
        follow = init_follow(contact['external_userid'], info)
        follow.client = external
        follow
      end
      self.class.transaction do
        fs.each(&:save)
      end

      next_cursor = r['next_cursor']
      sync_externals(cursor: next_cursor) if next_cursor.present?

      r
    end

    def sync_external(external_userid, **options)
      r = (corp || app).api.item(external_userid, **options)
      unless r['errcode'] == 0
        logger.debug "\e[35m  Sync External Err info: #{r}  \e[0m"
        return
      end

      item = r.fetch('external_contact', {})
      external = init_external(item)

      follow_infos = r.fetch('follow_user', [])
      info = follow_infos.find(&->(i){ i['userid'] == user_id })
      logger.debug "\e[35m  Corp id: #{info}  \e[0m"
      if info
        follow = init_follow(item['external_userid'], info)
        follow.client = external

        self.class.transaction do
          follow.save
          self.save
        end
      elsif r['next_cursor']
        sync_external(external_userid, cursor: r['next_cursor'])
      end

      external
    end

    def init_external(contact)
      external = Profiled::Profile.find_or_initialize_by(external_userid: contact['external_userid'])
      external.organ_id = organ&.id
      external.external_type = contact['type']
      external.nick_name = contact['name']
      external.avatar_url = contact['avatar']
      external.gender = GENDER[contact['gender']]
      external.assign_attributes contact.slice('position', 'corp_name', 'corp_full_name', 'unionid')
      external
    end

    def init_follow(external_userid, info)
      follow = member.maintains.find_or_initialize_by(external_userid: external_userid)
      follow.assign_attributes info.slice('remark', 'state', 'oper_userid', 'add_way', 'remark_mobiles')
      #follow.note = info['description']
      follow.member_id = member.id
      follow
    end

    def active_info
      suite.provider.api.active_info(corp_id, user_id)
    end

    # 激活码详情：https://developer.work.weixin.qq.com/document/path/95552
    def active_account(type = 2)
      rest_code = corp.list_codes.find(&->(i){ i['type'] == type && [1, 4].include?(i['status']) })
      return unless rest_code

      suite.provider.api.active_account(corp_id, user_id, rest_code['active_code'])
    end

    def authorized_token
      authorized_tokens.find(&:effective?) || authorized_tokens.create
    end

  end
end
