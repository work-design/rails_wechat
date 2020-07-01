module RailsWechat::OauthUser::WechatUser
  extend ActiveSupport::Concern

  included do
    attribute :provider, :string, default: 'wechat'
    attribute :remark, :string

    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid

    has_many :wechat_requests, dependent: :delete_all
    has_many :wechat_subscribeds, dependent: :delete_all
    has_many :wechat_user_tags, dependent: :destroy
    has_many :wechat_tags, through: :wechat_user_tags

    after_save_commit :sync_remark_later, if: -> { saved_change_to_remark? }
  end

  def sync_remark_later
    WechatUserJob.perform_later(self)
  end

  def sync_remark_to_wechat
    wechat_app.api.user_update_remark(uid, remark)
  rescue Wechat::WechatError => e
    logger.info e.message
  end

  def sync_user_info
    userinfo_url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{uid}"
    user_response = HTTPX.get(userinfo_url)
    res = JSON.parse(user_response.to_s)

    if res['errcode'].present?
      self.errors.add :base, "#{res['errcode']}, #{res['errmsg']}"
    end

    assign_profile_info(res.slice('nickname', 'headimgurl'))
    assign_user_info(res.slice('unionid'))
    self
  end

  def assign_info(oauth_params)
    info_params = oauth_params.fetch('info', {})
    assign_profile_info(info_params)

    raw_info = oauth_params.dig('extra', 'raw_info') || {}
    assign_user_info(raw_info)

    credential_params = oauth_params.fetch('credentials', {})
    credential_params['access_token'] = credential_params['token']
    assign_token_info(credential_params)
  end

  def assign_token_info(credential_params)
    self.access_token = credential_params['access_token']
    self.refresh_token = credential_params['refresh_token']
    self.expires_at = credential_params['expires_in']
  end

  def assign_profile_info(info_params)
    self.name = info_params['nickname']
    self.avatar_url = info_params['headimgurl']
  end

  def assign_user_info(raw_info)
    self.unionid = raw_info['unionid']
    self.app_id ||= raw_info['app_id']
    if self.unionid && self.same_oauth_user
      self.user_id ||= same_oauth_user.user_id
      self.account_id ||= same_oauth_user.account_id
    end
  end

  def save_info(oauth_params)
    assign_info(oauth_params)
    self.save
  end

end
