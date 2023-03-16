module Wechat
  module Model::Payee::PartnerPayee
    extend ActiveSupport::Concern

    included do
      belongs_to :partner
    end

    def api
      return @api if defined? @api
      @api = WxPay::Api::Partner.new(payee: self, partner: partner)
    end

    def key_v3
      partner.key_v3
    end

  end
end
