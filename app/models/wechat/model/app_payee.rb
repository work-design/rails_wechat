module Wechat
  module Model::AppPayee
    extend ActiveSupport::Concern

    included do
      attribute :appid, :string, index: true
      attribute :domain, :string

      belongs_to :app, foreign_key: :appid, primary_key: :appid, counter_cache: true
      belongs_to :payee

      has_many :receivers
    end

    def api
      return @api if defined? @api
      if payee.is_a?(PartnerPayee) && payee.partner
        @api = WxPay::Api::Partner.new(payee: payee, appid: appid)
      else
        @api = WxPay::Api::Mch.new(payee: payee, appid: appid)
      end
    end

  end
end
