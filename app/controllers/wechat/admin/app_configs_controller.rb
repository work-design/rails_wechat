module Wechat
  class Admin::AppConfigsController < Admin::BaseController
    before_action :set_app
    before_action :set_app_config, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_app_config, only: [:new, :create]

    def index
      @app_configs = @app.app_configs.page(params[:page])
    end

    private
    def set_app_config
      @app_config = @app.app_configs.find params[:id]
    end

    def set_new_app_config
      @app_config = @app.app_configs.build(app_config_params)
    end

    def app_config_params
      params.fetch(:app_config, {}).permit(
        :key,
        :value
      )
    end

  end
end
