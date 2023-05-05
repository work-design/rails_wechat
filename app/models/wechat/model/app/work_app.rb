module Wechat
  module Model::App::WorkApp
    extend ActiveSupport::Concern

    included do
      validates :agentid, presence: true

      alias_attribute :corpid, :appid
      alias_attribute :corpsecret, :secret

      has_many :corp_users, ->(o){ where(suite_id: nil, organ_id: o.organ_id) }, primary_key: :appid, foreign_key: :corp_id
    end

    def init_corp
      self.organ.update corp_id: self.appid
    end

    def sync_departments
      r = api.department
      return unless r['errcode'] == 0
      r['department'].each do |dep|
        depart = organ.departments.find_or_initialize_by(wechat_id: dep['id'])
        depart.name = dep['name']
        depart.save
      end
    end

    def js_login(**url_options)
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', id: id, host: self.domain
      {
        appid: appid,
        agentid: agentid,
        redirect_uri: ERB::Util.url_encode(Rails.application.routes.url_for(**url_options)),
        state: Com::State.create(host: host, controller: '/me/home')
      }
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Work.new(self)
    end

    def oauth2_url(scope: 'snsapi_privateinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults! controller: 'wechat/apps', action: 'login', id: id, host: self.domain
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
      logger.debug "\e[35m  getuserinfo: #{result}  \e[0m"
      corp_user = corp_users.find_or_initialize_by(userid: result['UserId'])
      corp_user.device_id = result['DeviceId'] if result['DeviceId'].present?
      corp_user.user_ticket = result['user_ticket']
      corp_user.ticket_expires_at = Time.current + result['expires_in'].to_i
      corp_user
    end

  end
end
