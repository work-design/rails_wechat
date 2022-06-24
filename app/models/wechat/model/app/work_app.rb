module Wechat
  module Model::App::WorkApp
    extend ActiveSupport::Concern

    included do
      validates :agentid, presence: true

      alias_attribute :corpid, :appid
      alias_attribute :corpsecret, :secret

      has_many :corp_users, ->{ where(suite_id: nil) }, primary_key: :appid, foreign_key: :corp_id
    end

    def init_corp
      self.organ.update corp_id: self.appid
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
      result = api.getuserinfo(code)

      corp_user = corp_users.find_or_initialize_by(user_id: result['UserId'])
      corp_user.device_id = result['DeviceId']
      corp_user.user_ticket = result['user_ticket']

      if result['user_ticket']
        detail = api.user_detail(result['user_ticket'])
        if detail['errcode'] == 0
          corp_user.assign_attributes detail.slice('gender', 'qr_code')
          corp_user.identity = detail['mobile']
          corp_user.avatar_url = detail['avatar']
        end
      end

      corp_user.save
      corp_user
    end

  end
end
