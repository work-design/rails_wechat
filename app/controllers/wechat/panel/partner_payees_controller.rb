module Wechat
  class Panel::PartnerPayeesController < Panel::BaseController
    before_action :set_partner
    before_action :set_partner_payee, only: [:show, :edit, :update, :destroy, :actions, :organ]
    before_action :set_new_partner_payee, only: [:new, :create]

    def index
      @partner_payees = @partner.payees.includes(:organ).page(params[:page])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
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
        :organ_id,
        :mch_id
      )
    end

  end
end
