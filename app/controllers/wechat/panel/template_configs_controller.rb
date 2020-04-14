class Wechat::Panel::TemplateConfigsController < Wechat::Panel::BaseController
  before_action :set_template_config, only: [:show, :edit, :update, :destroy]

  def index
    @template_configs = TemplateConfig.includes(:template_key_words).page(params[:page])
  end

  def new
    @template_config = TemplateConfig.new
  end

  def create
    @template_config = TemplateConfig.new(template_config_params)

    unless @template_config.save
      render :new, locals: { model: @template_config }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @template_config.assign_attributes(template_config_params)

    unless @template_config.save
      render :edit, locals: { model: @template_config }, status: :unprocessable_entity
    end
  end

  def destroy
    @template_config.destroy
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
