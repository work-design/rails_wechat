class Wechat::Admin::WechatTagsController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_tag, only: [:show, :edit, :update]

  def index
    q_params = {}
    q_params.merge! params.permit(:name)
    
    @wechat_tag_defaults = WechatTagDefault.all
    @default_wechat_tags = @wechat_app.wechat_tags.where.not(wechat_tag_default_id: nil)
    @wechat_tags = @wechat_app.wechat_tags.where(wechat_tag_default_id: nil).default_where(q_params).order(id: :asc).page(params[:page])
  end

  def new
    @wechat_tag = @wechat_app.wechat_tags.build
  end

  def create
    @wechat_tag = @wechat_app.wechat_tags.build(wechat_tag_params)

    respond_to do |format|
      if @wechat_tag.save
        format.html.phone
        format.html { redirect_to admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.js { redirect_back fallback_location: admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.json { render :show }
      end
    end
  end
  
  def sync
    @wechat_app.sync_wechat_tags
    redirect_to admin_wechat_app_wechat_tags_url(@wechat_app)
  end

  def show
  end

  def edit
  end

  def update
    @wechat_tag.assign_attributes(wechat_tag_params)

    respond_to do |format|
      if @wechat_tag.save
        format.html.phone
        format.html { redirect_to admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.js { redirect_back fallback_location: admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_app_wechat_tags_url(@wechat_app) }
        format.json { render :show }
      end
    end
  end

  def destroy
    if params[:wechat_tag_default_id].present?
      @wechat_tag = @wechat_app.wechat_tags.find_by(wechat_tag_default_id: params[:wechat_tag_default_id])
    else
      set_wechat_tag
    end
    @wechat_tag.destroy
    redirect_to admin_wechat_app_wechat_tags_url(@wechat_app)
  end

  private
  def set_wechat_tag
    @wechat_tag = @wechat_app.wechat_tags.find(params[:id])
  end

  def wechat_tag_params
    params.fetch(:wechat_tag, {}).permit(
      :name,
      :wechat_tag_default_id
    )
  end

end
