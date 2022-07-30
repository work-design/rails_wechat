module Wechat
  class Panel::TemplateConfigsController < Panel::BaseController
    before_action :set_template_config, only: [:show, :edit, :update, :sync, :apps, :destroy]
    before_action :set_app, only: [:sync]

    def index
      @template_configs = TemplateConfig.includes(:template_key_words).page(params[:page])
    end

    def apps
      @apps = PublicApp.page(params[:page])
      @appids = @template_config.templates.pluck(:appid)
    end

    def sync
      @template_config.sync_to_wechat(@app)
    end

    private
    def set_app
      @app = App.find_by appid: params[:appid]
    end

    def set_template_config
      @template_config = TemplateConfig.find(params[:id])
    end

    def template_config_params
      params.fetch(:template_config, {}).permit(
        :type,
        :title,
        :tid,
        :description,
        :notifiable_type,
        :code,
        template_key_words_attributes: {}
      )
    end

  end
end
