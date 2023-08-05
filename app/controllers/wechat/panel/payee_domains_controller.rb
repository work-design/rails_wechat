module Wechat
  class Panel::PayeeDomainsController < Panel::BaseController
    before_action :set_payee
    before_action :set_payee_domain, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_payee_domain, only: [:new, :create]
    before_action :set_domains, only: [:new, :create, :edit, :update]

    def index
      q_params = {}

      @payee_domains = @payee.payee_domains.default_where(q_params)
    end

    private
    def set_payee
      @payee = Payee.find params[:payee_id]
    end

    def set_payee_domain
      @payee_domain = @payee.payee_domains.find params[:id]
    end

    def set_new_payee_domain
      @payee_domain = @payee.payee_domains.build(payee_domain_params)
    end

    def set_domains
      @organ_domains = @payee.organ.organ_domains
    end

    def payee_domain_params
      params.fetch(:payee_domain, {}).permit(
        :domain
      )
    end
  end
end
