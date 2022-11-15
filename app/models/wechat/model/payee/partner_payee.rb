module Wechat
  module Model::Payee::PartnerPayee
    extend ActiveSupport::Concern

    included do
      belongs_to :partner, optional: true
    end

    def api
      return @api if defined? @api
      if payee.partner
        @api = WxPay::Api::Partner.new(self)
      else
        @api = WxPay::Api::Mch.new(self)
      end
    end
  end
end
