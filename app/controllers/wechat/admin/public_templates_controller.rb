class Wechat::Admin::PublicTemplatesController < Wechat::Admin::BaseController
  before_action :set_public_template, only: [:show, :edit, :update, :destroy]

  def index
    @public_templates = PublicTemplate.page(params[:page])
  end

  def new
    @public_template = PublicTemplate.new
  end

  def create
    @public_template = PublicTemplate.new(public_template_params)

    unless @public_template.save
      render :new, locals: { model: @public_template }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @public_template.assign_attributes(public_template_params)

    unless @public_template.save
      render :edit, locals: { model: @public_template }, status: :unprocessable_entity
    end
  end

  def destroy
    @public_template.destroy
  end

  private
  def set_public_template
    @public_template = PublicTemplate.find(params[:id])
  end

  def public_template_params
    params.fetch(:public_template, {}).permit(
      :title,
      :tid,
      :kid_list,
      :description
    )
  end

end
