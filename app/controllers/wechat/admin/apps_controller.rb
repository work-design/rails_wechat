module Wechat
  class Admin::AppsController < Admin::BaseController
    before_action :set_app, only: [:show, :info, :edit, :edit_cert, :update_cert, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id)

      @apps = App.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @app = App.new
    end

    def create
      @app = App.find_or_initialize_by(appid: app_params[:appid])
      if @app.organ
        @app.errors.add :base, '该账号已在其他组织添加，请联系客服'
      end
      @app.assign_attributes app_params

      unless @app.save
        render :new, locals: { model: @app }, status: :unprocessable_entity
      end
    end

    def show
    end

    def info
    end

    def edit_cert
    end

    def update_cert
      pkcs12 = WxPay.set_apiclient_by_pkcs12(params[:cert].read, @app.mch_id)

      @app.apiclient_cert = pkcs12.certificate
      @app.apiclient_key = pkcs12.key
      @app.save
    end

    def edit
    end

    def update
      @app.assign_attributes(app_params)

      unless @app.save
        render :edit, locals: { model: @app }, status: :unprocessable_entity
      end
    end

    def destroy
      @app.destroy
    end

    private
    def set_app
      @app = App.default_where(default_params).find(params[:id])
    end

    def app_params
      p = params.fetch(:app, {}).permit(
        :type,
        :name,
        :enabled,
        :appid,
        :secret,
        :agentid,
        :mch_id,
        :key,
        :key_v3,
        :encrypt_mode,
        :serial_no
      )
      p.merge! default_form_params
    end

  end
end
