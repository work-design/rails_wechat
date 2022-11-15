module Wechat
  module Model::Payee::PartnerPayee
    extend ActiveSupport::Concern

    included do
      belongs_to :partner
    end

    def api
      return @api if defined? @api
      @api = WxPay::Api::Partner.new(payee: self)
    end
  end
end
