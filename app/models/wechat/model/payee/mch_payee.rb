module Wechat
  module Model::Payee::MchPayee
    extend ActiveSupport::Concern

    included do
      belongs_to :partner_payee, foreign_key: :mch_id, primary_key: :mch_id, optional: true
    end

    def api
      return @api if defined? @api

      if partner_payee
        @api = WxPay::Api::Partner.new(payee: partner_payee, partner: partner_payee.partner)
      else
        @api = WxPay::Api::Mch.new(payee: self)
      end
    end

  end
end
