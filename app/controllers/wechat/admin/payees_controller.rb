module Wechat
  class Admin::PayeesController < Admin::BaseController
    before_action :set_app
    before_action :set_payee, only: [:show, :edit, :update, :destroy, :actions, :edit_cert, :update_cert]
    before_action :set_new_payee, only: [:new, :create]

    def edit_cert
    end

    def update_cert
      if params[:p12].present?
        pkcs12 = WxPay::Utils.set_apiclient_by_pkcs12(params[:p12].read, @app.mch_id)
        @app.apiclient_cert = pkcs12.certificate
        @app.apiclient_key = pkcs12.key
      else
        @app.apiclient_cert = params[:cert].read
        @app.apiclient_key = params[:key].read
      end

      @app.save
    end

    private
    def set_app
      @app = App.find_by appid: params[:app_id]
    end

    def set_payee
      @payee = @app.payees.find params[:id]
    end

    def set_new_payee
      @payee = @app.payees.build(payee_params)
    end

    def payee_params
      p = params.fetch(:payee, {}).permit(
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
