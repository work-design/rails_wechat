module Wechat
  class Panel::AppsController < Panel::BaseController
    before_action :set_wechat_app, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id)

      @wechat_apps = App.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @app = App.new
    end

    def create
      @app = App.find_or_initialize_by(appid: wechat_app_params[:appid])
      if @app.organ
        @app.errors.add :base, '该账号已在其他组织添加，请联系客服'
      end
      @app.assign_attributes wechat_app_params

      unless @app.save
        render :new, locals: { model: @app }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @app.assign_attributes(wechat_app_params)

      unless @app.save
        render :edit, locals: { model: @app }, status: :unprocessable_entity
      end
    end

    def destroy
      @app.destroy
    end

    private
    def set_wechat_app
      @app = App.find(params[:id])
    end

    def wechat_app_params
      params.fetch(:app, {}).permit(
        :type,
        :name,
        :shared,
        :appid,
        :secret,
        :agentid,
        :mch_id,
        :key,
        :key_v3,
        :encrypt_mode,
        :serial_no
      )
    end

  end
end
