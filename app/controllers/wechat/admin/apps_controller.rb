module Wechat
  class Admin::AppsController < Admin::BaseController
    before_action :set_app, only: [:show, :info, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:id, :type, :appid)

      @apps = Agency.default_where(q_params).order(id: :asc).page(params[:page])
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

    def info
    end

    private
    def set_app
      @app = Agency.default_where(default_params).find_by(appid: params[:appid])
    end

    def set_new_app
      @app = App.new(app_params)
    end

    def app_params
      p = params.fetch(:app, {}).permit(
        :type,
        :name,
        :enabled,
        :inviting,
        :appid,
        :secret,
        :encrypt_mode,
        :domain,
        :weapp_id
      )
      p.merge! default_form_params
    end

  end
end
