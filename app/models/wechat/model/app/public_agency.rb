# frozen_string_literal: true

module Wechat
  module Model::App::PublicAgency
    extend ActiveSupport::Concern

    included do
      attribute :ticket, :string

      after_save_commit :deal_ticket, if: -> { ticket.present? && saved_change_to_ticket? }
    end

    def domain
      organ&.host
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Public.new(self)
    end

    def deal_ticket
      r = api.fast_register(ticket)
      if r['errcode'] == 0
        agency_info = platform.api.query_auth(r['authorization_code'])
        agency = platform.agencies.find_or_initialize_by(appid: agency_info['authorizer_appid'])
        agency.store_access_token(agency_info)
      else
        r
      end
    end

    def disabled_func_infos
      return unless platform.public_agency
      platform.public_agency.func_infos - func_infos
    end

    def oauth2_url(scope: 'snsapi_userinfo', state: SecureRandom.hex(16), **url_options)
      url_options.with_defaults!(
        controller: 'wechat/agencies',
        action: 'login',
        appid: appid,
        host: oauth_domain.presence || platform.domain
      )
      if Rails.configuration.x.appid
        url_options.merge! auth_appid: Rails.configuration.x.appid
      end

      h = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state,
        component_appid: platform_appid
      }
      logger.debug "\e[35m  Agency Oauth2: #{h}  \e[0m"
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{h.to_query}#wechat_redirect"
    end

    def fast_url
      url = URI('https://mp.weixin.qq.com/cgi-bin/fastregisterauth')
      url.query = {
        component_appid: platform.appid,
        appid: appid,
        copy_wx_verify: 1,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/agencies', action: 'callback', id: id, host: platform.domain)
      }.to_query
      url.to_s
    end

  end
end
