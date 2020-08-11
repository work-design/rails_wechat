module RailsWechat::WechatAuth
  extend ActiveSupport::Concern

  included do
    attribute :auth_code, :string
    attribute :auth_code_expires_at, :datetime
    attribute :testcase, :boolean, default: false

    belongs_to :wechat_platform

    after_create_commit :deal_auth_code
  end

  def deal_auth_code
    r = wechat_platform.api.query_auth(auth_code)
    return unless r
    agency = wechat_platform.wechat_agencies.find_or_initialize_by(appid: r['authorizer_appid'])
    agency.store_access_token(r)
    deal_test_case(agency) if testcase
  end

  # 第三方平台上线测试用例2
  # 测试公众号使用客服消息接口处理用户消息
  def deal_test_case(agency)
    text_service = agency.wechat_services.build(type: 'TextService')
    text_service.value = "#{auth_code}_from_api"
    text_service.save
    text_service.do_send
  end

end
