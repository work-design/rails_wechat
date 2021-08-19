module Wechat
  class Admin::TemplatesController < Admin::BaseController
    before_action :set_app
    before_action :set_template, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @templates = @app.templates.default_where(q_params).page(params[:page])
      template_config_ids = @templates.pluck(:template_config_id)
      @template_configs = TemplateConfig.where.not(id: template_config_ids)
    end

    def create
      @template = @app.templates.build(template_params)

      unless @template.save
        render :new, locals: { model: @template }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_templates
    end

    private
    def set_app
      @app = App.default_where(default_params).find_by id: params[:app_id]
    end

    def set_template
      @template = Template.find(params[:id])
    end

    def template_params
      params.fetch(:template, {}).permit(
        :app_id,
        :template_config_id,
        :template_id,
        :title,
        :content,
        :example,
        :template_type
      )
    end

  end
end
