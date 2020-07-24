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
    agency.store_access_token(r)
  end

end
