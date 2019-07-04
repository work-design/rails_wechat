class Wechat::Admin::WechatTagDefaultsController < Wechat::Admin::BaseController
  before_action :set_wechat_tag_default, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_tag_defaults = WechatTagDefault.page(params[:page])
  end

  def new
    @wechat_tag_default = WechatTagDefault.new
  end

  def create
    @wechat_tag_default = WechatTagDefault.new(wechat_tag_default_params)

    respond_to do |format|
      if @wechat_tag_default.save
        format.html.phone
        format.html { redirect_to admin_wechat_tag_defaults_url }
        format.js { redirect_back fallback_location: admin_wechat_tag_defaults_url }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_wechat_tag_defaults_url }
        format.json { render :show }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_tag_default.assign_attributes(wechat_tag_default_params)

    respond_to do |format|
      if @wechat_tag_default.save
        format.html.phone
        format.html { redirect_to admin_wechat_tag_defaults_url }
        format.js { redirect_back fallback_location: admin_wechat_tag_defaults_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_tag_defaults_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_tag_default.destroy
    redirect_to admin_wechat_tag_defaults_url
  end

  private
  def set_wechat_tag_default
    @wechat_tag_default = WechatTagDefault.find(params[:id])
  end

  def wechat_tag_default_params
    params.fetch(:wechat_tag_default, {}).permit(
      :name,
      :default_type
    )
  end

end
