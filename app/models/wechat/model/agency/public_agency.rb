# frozen_string_literal: true

module Wechat
  module Model::Agency::PublicAgency
    extend ActiveSupport::Concern

    included do
      attribute :ticket, :string

      after_create_commit :deal_ticket, if: -> { ticket.present? }
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
        agency = platform.agencies.find_or_initialize_by(appid: r['appid'])
      else
        r
      end
    end

    def disabled_func_infos
      return unless platform.public_agency
      platform.public_agency.func_infos - func_infos
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
