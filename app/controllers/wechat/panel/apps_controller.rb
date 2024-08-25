module Wechat
  class Panel::AppsController < Panel::BaseController
    before_action :set_app, only: [:show, :edit, :key, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :type, :appid)

      @apps = App.includes(:organ).default_where(q_params).order(id: :desc).page(params[:page])
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

    private
    def set_app
      @app = App.find(params[:id])
    end

    def app_params
      params.fetch(:app, {}).permit(
        :type,
        :nick_name,
        :appid,
        :secret,
        :encrypt_mode,
        :inviting,
        :domain,
        :oauth_domain,
        :weapp_id,
        :platform_appid,
        :debug,
        :global
      )
    end

  end
end
