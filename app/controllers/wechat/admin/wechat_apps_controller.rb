module Wechat
  class Admin::WechatAppsController < Admin::BaseController
    before_action :set_wechat_app, only: [:show, :info, :edit, :edit_cert, :update_cert, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id)

      @wechat_apps = WechatApp.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @wechat_app = WechatApp.new
    end

    def create
      @wechat_app = WechatApp.find_or_initialize_by(appid: wechat_app_params[:appid])
      if @wechat_app.organ
        @wechat_app.errors.add :base, '该账号已在其他组织添加，请联系客服'
      end
      @wechat_app.assign_attributes wechat_app_params

      unless @wechat_app.save
        render :new, locals: { model: @wechat_app }, status: :unprocessable_entity
      end
    end

    def show
    end

    def info
    end

    def edit_cert
    end

    def update_cert
      pkcs12 = WxPay.set_apiclient_by_pkcs12(params[:cert].read, @wechat_app.mch_id)

      @wechat_app.apiclient_cert = pkcs12.certificate
      @wechat_app.apiclient_key = pkcs12.key
      @wechat_app.save
    end

    def edit
    end

    def update
      @wechat_app.assign_attributes(wechat_app_params)

      unless @wechat_app.save
        render :edit, locals: { model: @wechat_app }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_app.destroy
    end

    private
    def set_wechat_app
      @wechat_app = WechatApp.default_where(default_params).find(params[:id])
    end

    def wechat_app_params
      p = params.fetch(:wechat_app, {}).permit(
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
