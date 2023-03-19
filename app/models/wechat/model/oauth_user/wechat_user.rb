module Wechat
  module Model::OauthUser::WechatUser
    extend ActiveSupport::Concern

    included do
      attribute :provider, :string, default: 'wechat'
      attribute :remark, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :appid, :string
      attribute :uid, :string, index: true
      attribute :unionid, :string, index: true
      attribute :access_token, :string
      attribute :expires_at, :datetime
      attribute :refresh_token, :string
      attribute :unsubscribe_at, :datetime

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :user_inviter, class_name: 'Auth::User', optional: true
      belongs_to :member_inviter, class_name: 'Org::Member', optional: true
      has_many :org_members, class_name: 'Org::Member', primary_key: :uid, foreign_key: :wechat_openid

      has_one :request, -> { where(init_wechat_user: true) }, primary_key: :uid, foreign_key: :open_id
      has_many :requests, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :user_tags, primary_key: :uid, foreign_key: :open_id, dependent: :destroy_async
      has_many :tags, through: :user_tags
      has_many :notices, ->(o) { where(appid: o.appid) }, primary_key: :uid, foreign_key: :open_id
      has_many :externals, primary_key: :unionid, foreign_key: :unionid

      before_save :auto_link, if: -> { unionid.present? && unionid_changed? }
      after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
      after_save_commit :auto_join_organ, if: -> { member_inviter && saved_change_to_member_inviter_id? }
      after_save_commit :prune_user_tags, if: -> { unsubscribe_at.present? && saved_change_to_unsubscribe_at? }
    end

    def try_match
      app.api.menu_trymatch(uid)
    end

    def auto_link
      return unless same_oauth_user

      self.identity ||= same_oauth_user.identity
      self.name ||= same_oauth_user.name
      self.avatar_url ||= same_oauth_user.avatar_url
    end

    def auto_join_organ
      org_members.find_by(organ_id: member_inviter.organ_id) || org_members.create(organ_id: member_inviter.organ_id, state: 'pending_trial')
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
      params = {
        access_token: access_token,
        openid: uid
      }
      user_response = HTTPX.get('https://api.weixin.qq.com/sns/userinfo', params: params)
      res = JSON.parse(user_response.to_s)
      logger.debug "\e[35m  Result: #{res}  \e[0m"

      if res['errcode'].present?
        self.errors.add :base, "#{res['errcode']}, #{res['errmsg']}"
      end

      self.name = res['nickname']
      self.avatar_url = res['headimgurl']
      self
    end

    def refresh_access_token
      params = {
        appid: appid,
        grant_type: 'refresh_token',
        refresh_token: refresh_token
      }

      response = HTTPX.get 'https://api.weixin.qq.com/sns/oauth2/refresh_token', params: params
      res = JSON.parse(response.to_s)
      self.assign_attributes res.slice('access_token', 'refresh_token')
      self.expires_at = Time.current + res['expires_in'].to_i
      self.save
      res
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

  end
end
