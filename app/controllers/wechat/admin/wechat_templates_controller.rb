module Wechat
  class Admin::WechatTemplatesController < Admin::BaseController
    before_action :set_app
    before_action :set_wechat_template, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      @wechat_templates = @app.wechat_templates.default_where(q_params).page(params[:page])
      template_config_ids = @wechat_templates.pluck(:template_config_id)
      @template_configs = TemplateConfig.where.not(id: template_config_ids)
    end

    def create
      @wechat_template = @app.wechat_templates.build(wechat_template_params)

      unless @wechat_template.save
        render :new, locals: { model: @wechat_template }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_wechat_templates
    end

    def show
    end

    def edit
    end

    def update
      @wechat_template.assign_attributes(wechat_template_params)

      unless @wechat_template.save
        render :edit, locals: { model: @wechat_template }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_template.destroy
    end

    private
    def set_app
      @app = App.default_where(default_params).find_by id: params[:app_id]
    end

    def set_wechat_template
      @wechat_template = WechatTemplate.find(params[:id])
    end

    def wechat_template_params
      params.fetch(:wechat_template, {}).permit(
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
