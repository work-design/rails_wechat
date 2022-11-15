module Wechat
  class Admin::PayeesController < Admin::BaseController
    before_action :set_payee, only: [:show, :edit, :update, :destroy, :actions, :edit_cert, :update_cert]
    before_action :set_new_payee, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params

      @payees = Payee.default_where(q_params)
    end

    def edit_cert
    end

    def update_cert
      if params[:p12].present?
        pkcs12 = WxPay::Utils.set_apiclient_by_pkcs12(params[:p12].read, @payee.mch_id)
        @payee.apiclient_cert = pkcs12.certificate
        @payee.apiclient_key = pkcs12.key
      else
        @payee.apiclient_cert = params[:cert].read if params[:cert].respond_to?(:read)
        @payee.apiclient_key = params[:key].read if params[:key].respond_to?(:read)
      end

      @payee.save
    end

    private
    def set_payee
      @payee = Payee.find params[:id]
    end

    def set_new_payee
      @payee = Payee.new(payee_params)
    end

    def payee_params
      p = params.fetch(:payee, {}).permit(
        :name,
        :mch_id,
        :key,
        :key_v3,
        :serial_no,
        :apiclient_cert,
        :apiclient_key
      )
      p.merge! default_form_params
    end
  end
end
