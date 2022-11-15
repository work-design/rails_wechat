module Wechat
  class Panel::PartnerPayeesController < Panel::BaseController
    before_action :set_partner
    before_action :set_partner_payee, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_partner_payee, only: [:new, :create]

    def index
      @partner_payees = @partner.payees.page(params[:page])
    end

    private
    def set_partner
      @partner = Partner.find params[:partner_id]
    end

    def set_partner_payee
      @partner_payee = @partner.payees.find params[:id]
    end

    def set_new_partner_payee
      @partner_payee = @partner.payees.build(partner_payee_params)
    end

    def partner_payee_params
      params.fetch(:partner_payee, {}).permit(
        :name,
        :mch_id
      )
    end

  end
end
