module RailsWechat::OauthUser::WechatUser
  extend ActiveSupport::Concern

  included do
    attribute :provider, :string, default: 'wechat'
    attribute :remark, :string

    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid, optional: true

    has_many :wechat_requests, foreign_key: :open_id, primary_key: :uid, dependent: :delete_all
    has_many :wechat_subscribeds, dependent: :delete_all
    has_many :wechat_user_tags, dependent: :destroy
    has_many :wechat_tags, through: :wechat_user_tags
    has_many :wechat_notices, foreign_key: :open_id, primary_key: :uid

    after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
    after_save_commit :sync_user_info_later, if: -> { saved_change_to_access_token? && (attributes['name'].blank? && attributes['avatar_url'].blank?) }
  end

  def name
    super.blank? ? "WechatUser_#{id}" : super
  end

  def sync_remark_later
    WechatUserJob.perform_later(self)
  end

  def sync_remark_to_wechat
    wechat_app.api.user_update_remark(uid, remark)
  rescue Wechat::WechatError => e
    logger.info e.message
  end

  def sync_user_info_later
    WechatUserInfoJob.perform_later(self)
  end

  def sync_user_info
    params = {
      access_token: access_token,
      openid: uid
    }
    user_response = HTTPX.get('https://api.weixin.qq.com/sns/userinfo', params: params)
    res = JSON.parse(user_response.to_s)

    if res['errcode'].present?
      self.errors.add :base, "#{res['errcode']}, #{res['errmsg']}"
    end

    self.name = res['nickname']
    self.avatar_url = res['headimgurl']
    self.save
  end

  def refresh_access_token
    params = {
      appid: app_id,
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    }

    response = HTTPX.get 'https://api.weixin.qq.com/sns/oauth2/refresh_token', params: params
    res = JSON.parse(response.to_s)
    self.assign_attributes res.slice('access_token', 'refresh_token')
    self.expires_at = Time.current + res['expires_in'].to_i
    self.save
  end

  def assign_user_info(raw_info)
    self.unionid = raw_info['unionid']
    self.app_id ||= raw_info['app_id']
    if self.unionid && self.same_oauth_user
      self.user_id ||= same_oauth_user.user_id
      self.account_id ||= same_oauth_user.account_id
    end
  end

end
