module Wechat
  module Model::App::WorkApp
    extend ActiveSupport::Concern

    included do
      validates :agentid, presence: true

      alias_attribute :corpid, :appid
      alias_attribute :corpsecret, :secret

      has_one :corp

      before_validation :init_corp
    end


    def init_corp
      corp || build_corp(suite_id: nil)
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Work.new(self)
    end

    def oauth2_url(scope: 'snsapi_privateinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', id: id, host: self.host
      h = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state,
        agentid: agentid
      }
      logger.debug "\e[35m  Oauth2 Options: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def generate_wechat_user(code)
      r = api.getuserinfo(code)
    end

  end
end
