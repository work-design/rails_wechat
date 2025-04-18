module Wechat
  module Model::CorpUser
    GENDER = {
      0 => 'unknown',
      1 => 'male',
      2 => 'female'
    }
    extend ActiveSupport::Concern

    included do
      attribute :corpid, :string
      attribute :suite_id, :string, index: true
      attribute :userid, :string, index: true
      attribute :device_id, :string
      attribute :user_ticket, :string
      attribute :ticket_expires_at, :datetime
      attribute :open_userid, :string
      attribute :open_id, :string
      attribute :identity, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :qr_code, :string
      attribute :department, :json
      attribute :follows_count, :integer, default: 0

      enum :gender, {
        male: '1',
        female: '2',
        unknown: '0'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :member, ->(o) { where(organ_id: o.organ_id) }, class_name: 'Org::Member', foreign_key: :userid, primary_key: :corp_userid, optional: true
      belongs_to :account, class_name: 'Auth::Account', foreign_key: :identity, primary_key: :identity, optional: true
      has_many :authorized_tokens, class_name: 'Auth::AuthorizedToken', primary_key: [:userid, :suite_id, :corpid, :identity], foreign_key: [:corp_userid, :suite_id, :appid, :identity], dependent: :nullify

      belongs_to :suite, foreign_key: :suite_id, primary_key: :suite_id, optional: true
      belongs_to :corp, ->(o) { where(suite_id: o.suite_id) }, foreign_key: :corpid, primary_key: :corpid, optional: true
      belongs_to :agent, foreign_key: :corpid, primary_key: :corpid, optional: true

      has_one :same_corp_user, ->(o) { where(corpid: o.corpid) }, class_name: self.name, primary_key: :userid, foreign_key: :userid
      has_many :same_corp_users, ->(o) { where(corpid: o.corpid) }, class_name: self.name, primary_key: :userid, foreign_key: :userid
      has_many :contacts, ->(o) { where(corpid: o.corpid, suite_id: o.suite_id) }, primary_key: :userid, foreign_key: :userid
      has_many :maintains, through: :member
      has_many :clients, through: :maintains

      before_validation :sync_organ, if: -> { corpid_changed? }
      before_validation :init_corp, if: -> { suite_id.present? && suite_id_changed? }
      after_save :auto_join_organ, if: -> { organ_id.present? && saved_change_to_organ_id? }
      after_save :init_account, if: -> { identity.present? && saved_change_to_identity? }
      after_create_commit :sync_externals_later
      after_create_commit :get_detail_later
    end

    def sync_organ
      if corp
        self.organ_id = corp.organ_id
      elsif agent
        self.organ_id = agent.organ_id
      end
    end

    def init_corp
      corp || build_corp(suite_id: suite_id)
    end

    def auto_join_organ
      return if member
      return unless organ

      member || create_member
      member.identity = identity
      member.save
    end

    def get_detail_later
      CorpUserDetailJob.perform_later(self)
    end

    def get_detail
      r = (suite || agent).api.user_detail(user_ticket)
      logger.debug "\e[35m  user_detail: #{r}  \e[0m"
      if r['errcode'] == 0
        self.assign_attributes r.slice('name', 'gender', 'qr_code', 'open_userid')
        self.avatar_url = r['avatar']
        self.identity = r['mobile'].presence || r['email'].presence
        self.save
      end
    end

    def get_open_id!
      r = agent.api.convert_to_openid(userid)
      logger.debug "\e[35m  openid: #{r}  \e[0m"
      self.open_id = r['openid']
      self.save
    end

    def sync_externals_later
      CorpSyncExternalsJob.perform_later(self)
    end

    def sync_externals(**options)
      r = api.batch(userid, **options)
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

    def api
      (corp || agent).api
    end

    def sync_external(external_userid, **options)
      r = api.item(external_userid, **options)
      logger.debug "\e[35m  Sync External: #{r}  \e[0m"
      return unless r['errcode'] == 0

      item = r.fetch('external_contact', {})
      external = init_external(item)

      follow_infos = r.fetch('follow_user', [])
      info = follow_infos.find(&->(i){ i['userid'] == userid })
      logger.debug "\e[35m  External Info: #{info}  \e[0m"
      if info
        follow = init_follow(item['external_userid'], info)
        follow.client = external
        follow.save
      elsif r['next_cursor']
        sync_external(external_userid, cursor: r['next_cursor'])
      end

      external
    end

    def init_account
      account || build_account
      account.confirmed = true
      account.save
    end

    def init_external(contact)
      external = Crm::Contact.find_or_initialize_by(external_userid: contact['external_userid'])
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
      follow.assign_attributes info.slice('remark', 'state', 'oper_userid', 'add_way', 'description', 'remark_mobiles')
      follow.member_id = member.id
      follow
    end

    def active_info
      suite.provider.api.active_info(corpid, userid)
    end

    # 激活码详情：https://developer.work.weixin.qq.com/document/path/95552
    def active_account(type = 2)
      rest_code = corp.list_codes.find(&->(i){ i['type'] == type && [1, 4].include?(i['status']) })
      return unless rest_code

      suite.provider.api.active_account(corpid, userid, rest_code['active_code'])
    end

    def authorized_token
      authorized_tokens.find(&:effective?) || authorized_tokens.create
    end

  end
end
