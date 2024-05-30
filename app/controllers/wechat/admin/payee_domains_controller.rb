module Wechat
  class Admin::PayeeDomainsController < Panel::PayeeDomainsController

    def index
      q_params = {}

      @payee_domains = @payee.payee_domains.default_where(q_params)
    end

    private
    def set_payee
      @payee = Payee.default_where(default_params).find params[:payee_id]
    end
  end
end
