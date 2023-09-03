module Wechat
  class Panel::TemplatesController < Panel::BaseController
    before_action :set_app
    before_action :set_template, only: [:show, :edit, :update, :destroy]
    before_action :set_new_template, only: [:new, :create]

    def index
      q_params = {}

      @templates = @app.templates.default_where(q_params).page(params[:page])
      #template_config_ids = @templates.pluck(:template_config_id)
      #@template_configs = TemplateConfig.where.not(id: template_config_ids)
    end

    def sync
      r = @app.sync_templates
    end

    private
    def set_template
      @template = Template.find(params[:id])
    end

    def set_new_template
      @template = @app.templates.build(template_params)
    end

    def template_params
      params.fetch(:template, {}).permit(
        :template_id,
        :title,
        :content,
        :example,
        :template_type
      )
    end

  end
end
