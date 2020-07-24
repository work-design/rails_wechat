module RailsWechat::WechatAgency
  extend ActiveSupport::Concern

  included do
    attribute :appid, :string
    attribute :access_token, :string
    attribute :access_token_expires_at, :datetime
    attribute :refresh_token, :string
    attribute :func_infos, :string, array: true

    belongs_to :wechat_platform
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
  end

  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

  def refresh_access_token
    r = wechat_platform.api.authorizer_token(appid, refresh_token)
    store_access_token(r)
  end

  def store_access_token(r)
    self.access_token = r['authorizer_access_token']
    self.access_token_expires_at = Time.current + r['expires_in'].to_i
    self.refresh_token = r['authorizer_refresh_token']
    self.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') } if r['func_info'].is_a?(Array)
    self.save
  end

end
