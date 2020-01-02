class Wechat::Admin::WechatTemplatesController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_template, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    @wechat_templates = @wechat_app.wechat_templates.default_where(q_params).page(params[:page])
    public_template_ids = @wechat_templates.pluck(:public_template_id)
    @public_templates = PublicTemplate.where.not(id: public_template_ids)
  end

  def create
    @wechat_template = @wechat_app.wechat_templates.build(wechat_template_params)

    unless @wechat_template.save
      render :new, locals: { model: @wechat_template }, status: :unprocessable_entity
    end
  end

  def sync
    r = @wechat_app.sync_wechat_templates
    redirect_to admin_wechat_app_wechat_templates_url(params[:wechat_app_id]), notice: r.to_s
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
  def set_wechat_app
    @wechat_app = WechatApp.default_where(default_params).find_by id: params[:wechat_app_id]
  end

  def set_wechat_template
    @wechat_template = WechatTemplate.find(params[:id])
  end

  def wechat_template_params
    params.fetch(:wechat_template, {}).permit(
      :wechat_app_id,
      :public_template_id,
      :template_id,
      :title,
      :content,
      :example,
      :template_type
    )
  end

end
