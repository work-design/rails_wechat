module Wechat
  class Panel::PartnersController < Panel::BaseController
    before_action :set_partner, only: [:show, :edit, :update, :destroy, :actions, :edit_cert, :update_cert]
    before_action :set_new_partner, only: [:new, :create]

    def index
      q_params = {}

      @partners = Partner.default_where(q_params)
    end

    def edit_cert
    end

    def update_cert
      if params[:p12].present?
        pkcs12 = WxPay::Utils.set_apiclient_by_pkcs12(params[:p12].read, @partner.mch_id)
        @partner.apiclient_cert = pkcs12.certificate
        @partner.apiclient_key = pkcs12.key
      else
        @partner.apiclient_cert = params[:cert].read if params[:cert].respond_to?(:read)
        @partner.apiclient_key = params[:key].read if params[:key].respond_to?(:read)
      end

      @partner.save
    end

    private
    def set_partner
      @partner = Partner.find params[:id]
    end

    def set_new_partner
      @partner = Partner.new(partner_params)
    end

    def partner_params
      params.fetch(:partner, {}).permit(
        :name,
        :appid,
        :mch_id,
        :key,
        :key_v3,
        :serial_no,
        :apiclient_cert,
        :apiclient_key
      )
    end
  end
end
