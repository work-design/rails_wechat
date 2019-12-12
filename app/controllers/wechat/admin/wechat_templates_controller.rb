class Wechat::Admin::WechatTemplatesController < Wechat::Admin::BaseController
  before_action :set_wechat_template, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_templates = WechatTemplate.page(params[:page])
  end

  def new
    @wechat_template = WechatTemplate.new
  end

  def create
    @wechat_template = WechatTemplate.new(wechat_template_params)

    unless @wechat_template.save
      render :new, locals: { model: @wechat_template }, status: :unprocessable_entity
    end
  end

  def sync
    r = @wechat_app.api.templates
    redirect_to admin_wechat_menus_url(wechat_app_id: @wechat_menu.wechat_app_id), notice: r.to_s
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
      :template_id,
      :title,
      :content,
      :example,
      :template_type
    )
  end

end
