module Wechat
  module Model::Payee::MchPayee
    extend ActiveSupport::Concern

    def api
      return @api if defined? @api
      @api = WxPay::Api::Mch.new(payee: self)
    end

  end
end
