# frozen_string_literal: true

module Wechat
  module Inner::PublicApp
    extend ActiveSupport::Concern

    def domain
      organ&.host
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Public.new(self)
    end

    def js_config(url = '/')
      refresh_jsapi_ticket unless jsapi_ticket_valid?
      js_hash = Wechat::Signature.signature(jsapi_ticket, url)
      js_hash.merge! appid: appid
      logger.debug "\e[35m  Current page is: #{url}, Hash: #{js_hash.inspect}  \e[0m"
      js_hash
    rescue => e
      logger.debug e.message
    end

  end
end
