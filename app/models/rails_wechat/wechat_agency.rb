module RailsWechat::WechatAgency
  extend ActiveSupport::Concern

  included do
    attribute :appid, :string
    attribute :access_token, :string
    attribute :access_token_expires_at, :datetime
    attribute :refresh_token, :string
    attribute :func_infos, :string, array: true
    attribute :nick_name, :string
    attribute :head_img, :string
    attribute :user_name, :string
    attribute :principal_name, :string
    attribute :alias_name, :string
    attribute :qrcode_url, :string
    attribute :business_info, :json
    attribute :service_type, :string
    attribute :verify_type, :string

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

  def store_info
    r = wechat_platform.api.get_authorizer_info(appid)
    self.assign_attributes r.slice('nick_name', 'head_img', 'user_name', 'principal_name', 'qrcode_url', 'business_info')
    self.alias_name = r['alias']
    self.service_type = r.dig('service_type_info', 'id')
    self.verify_type = r.dig('verify_type_info', 'id')
    self.save
  end

  def store_access_token(r)
    self.access_token = r['authorizer_access_token']
    self.access_token_expires_at = Time.current + r['expires_in'].to_i
    self.refresh_token = r['authorizer_refresh_token']
    self.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') } if r['func_info'].is_a?(Array)
    self.save
  end

end
