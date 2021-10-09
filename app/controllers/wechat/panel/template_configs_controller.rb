module Wechat
  class Panel::TemplateConfigsController < Panel::BaseController
    before_action :set_template_config, only: [:show, :edit, :update, :destroy]

    def index
      @template_configs = TemplateConfig.includes(:template_key_words).page(params[:page])
    end

    private
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
