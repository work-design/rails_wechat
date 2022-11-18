module Wechat
  module Model::Auth
    extend ActiveSupport::Concern

    included do
      attribute :auth_code, :string
      attribute :auth_code_expires_at, :datetime
      attribute :testcase, :boolean, default: false

      belongs_to :platform
      belongs_to :request, optional: true  # for testcase 2

      after_create_commit :deal_auth_code
    end

    def deal_auth_code
      r = platform.api.query_auth(auth_code)
      return unless r
      agency = platform.agencies.find_or_initialize_by(appid: r['authorizer_appid'])
      agency.store_access_token(r)
      deal_test_case(agency) if testcase
    end

    # 第三方平台上线测试用例2
    # 测试公众号使用客服消息接口处理用户消息
    def deal_test_case(agency)
      text_service = agency.services.build(type: 'TextService')
      text_service.open_id = request.open_id
      text_service.value = "#{auth_code}_from_api"
      text_service.save
      text_service.do_send
    end

  end
end
