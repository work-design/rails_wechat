module RailsWechat::WechatAuth
  extend ActiveSupport::Concern

  included do
    attribute :auth_code, :string
    attribute :auth_code_expires_at, :datetime

    belongs_to :wechat_platform

    after_create_commit :deal_auth_code
  end

  def deal_auth_code
    r = wechat_platform.api.query_auth(auth_code)
    agency = wechat_platform.wechat_agencies.find_or_initialize_by(appid: r['authorizer_appid'])
    agency.access_token = r['authorizer_access_token']
    agency.access_token_expires_at = Time.current + r['expires_in'].to_i
    agency.refresh_token = r['authorizer_refresh_token']
    agency.func_infos = r['func_info'].map { |i| i.dig('funcscope_category', 'id') }
    agency.save
  end

end
