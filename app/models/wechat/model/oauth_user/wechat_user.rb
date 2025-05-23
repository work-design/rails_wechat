module Wechat
  module Model::OauthUser::WechatUser
    extend ActiveSupport::Concern

    included do
      attribute :provider, :string, default: 'wechat'
      attribute :remark, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :appid, :string
      attribute :app_name, :string
      attribute :scene_tag, :string
      attribute :uid, :string, index: true
      attribute :unionid, :string, index: true
      attribute :access_token, :string
      attribute :expires_at, :datetime
      attribute :refresh_token, :string
      attribute :agency_oauth, :boolean, default: false
      attribute :unsubscribe_at, :datetime
      attribute :scope, :string
      attribute :auto_reply, :boolean, default: true

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :agency, foreign_key: :appid, primary_key: :appid, optional: true

      has_many :members, class_name: 'Org::Member', primary_key: :uid, foreign_key: :wechat_openid
      has_many :organs, -> { order(id: :asc) }, class_name: 'Org::Organ', through: :members
      has_many :contacts, ->{ where.not(unionid: nil) }, class_name: 'Crm::Contact', primary_key: :unionid, foreign_key: :unionid if defined? RailsCrm

      has_many :requests, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :messages, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :message_sends, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :user_tags, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :tags, through: :user_tags
      has_many :notices, ->(o) { where(appid: o.appid) }, primary_key: :uid, foreign_key: :open_id
      has_many :corp_external_users, ->(o) { where(uid: o.uid) }, primary_key: :unionid, foreign_key: :unionid

      before_validation :sync_from_app, if: -> { appid.present? && appid_changed? }
      after_save :sync_to_org_members, if: -> { saved_change_to_identity? }
      after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
      after_save_commit :prune_user_tags, if: -> { unsubscribe_at.present? && saved_change_to_unsubscribe_at? }
      after_save_commit :sync_user_info_later, if: -> { scope == 'snsapi_userinfo' && saved_change_to_scope? }
      after_save_commit :init_corp_external_user, if: -> { unionid.present? && saved_change_to_unionid? } if defined? RailsCrm
    end

    def sync_from_app
      if app
        self.organ_id = app.organ_id
        self.app_name = app.name
      end
    end

    def api
      return @api if defined? @api
      @api = Wechat::UserApi.new(self)
    end

    def try_match
      app.api.menu_trymatch(uid)
    end

    # Typing
    # CancelTyping
    def typing(command = 'Typing')
      app.api.message_custom_typing(uid, command)
    end

    def msg_send(msg)

    end

    def login!(state_id)
      state = Com::State.find_by(id: state_id)
      if state
        state.update destroyable: true
        authorized_token.update session_id: "#{state.session_id}_#{state_id}"

        SessionChannel.broadcast_to(
          state.session_id,
          url: state.url(auth_token: auth_token)
        )
      end
    end

    def sync_to_org_members
      members.each do |member|
        member.identity = identity
        member.name = name
        member.save
      end
    end

    def sync_remark_later
      WechatUserJob.perform_later(self)
    end

    def sync_remark_to_wechat
      return unless app
      app.api.user_update_remark(uid, remark)
    rescue Wechat::WechatError => e
      logger.info e.message
    end

    def sync_user_info
      res = api.userinfo(uid)
      logger.debug "\e[35m  Sync User Info: #{res}  \e[0m"

      if res['errcode'].present?
        self.errors.add :base, "#{res['errcode']}, #{res['errmsg']}"
      end

      self.name = res['nickname']
      self.avatar_url = res['headimgurl']
      self.save
      self
    end

    def sync_user_info_later
      UserInfoJob.perform_later(self)
    end

    def refresh_access_token
      if agency_oauth
        res = agency.platform.api.oauth2_refresh_token(refresh_token, appid)
      else
        res = api.refresh_token(refresh_token)
      end
      self.assign_attributes res.slice('access_token', 'refresh_token')
      self.expires_at = Time.current + res['expires_in'].to_i
      self.save
      res
    end

    def access_token_valid?
      return false unless expires_at.acts_like?(:time)
      expires_at > Time.current
    end

    def assign_info(oauth_params)
      info_params = oauth_params.fetch('info', {})
      self.name = info_params['nickname']
      self.avatar_url = info_params['headimgurl']

      raw_info = oauth_params.dig('extra', 'raw_info') || {}
      self.unionid = raw_info['unionid']
      self.appid ||= raw_info['app_id']

      credential_params = oauth_params.fetch('credentials', {})
      self.access_token = credential_params['token']
      self.refresh_token = credential_params['refresh_token']
      self.expires_at = Time.current + credential_params['expires_in'].to_i
    end

    def prune_user_tags
      user_tags.update_all(synced: false)
    end

    def init_contact(organ_id, member_id)
      init_user
      contact = contacts.find_or_initialize_by(organ_id: organ_id)
      contact.client_user = user
      contact.maintains.build(member_id: member_id)
    end

    def init_member(organ_id)
      members.find_by(organ_id: organ_id) || members.build(organ_id: organ_id, state: 'pending_trial')
    end

    def init_corp_external_user
      if contacts.present?
        contacts.each do |contact|
          contact.client_user_id ||= user_id
          contact.client_member ||= members[0]
          contact.save
        end
      elsif app&.organ
        corp = Corp.where(organ_id: app.organ.self_and_ancestor_ids).take
        return unless corp
        corp_external_users.present? || corp_external_users.create(corpid: corp.corpid)
      end
    end


  end
end
