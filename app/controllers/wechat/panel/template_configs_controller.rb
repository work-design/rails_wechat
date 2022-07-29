module Wechat
  class Panel::TemplateConfigsController < Panel::BaseController
    before_action :set_app
    before_action :set_template_config, only: [:show, :edit, :update, :destroy]
    #before_action :set_new_template_config, only: [:new, :create]

    def index
      @template_configs = TemplateConfig.includes(:template_key_words).page(params[:page])
    end

    private
    def set_app
      @app = App.find_by appid: params[:appid]
    end

    def set_template_config
      @template_config = TemplateConfig.find(params[:id])
    end

    def set_new_template_config
      @template_config = @app.template_configs.build template_config_params
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
