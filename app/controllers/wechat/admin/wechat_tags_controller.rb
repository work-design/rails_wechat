class Wechat::Admin::WechatTagsController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_tag, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:name)
    
    @wechat_tags = @wechat_app.wechat_tags.default_where(q_params).order(id: :asc).page(params[:page])
    @wechat_tag_defaults = WechatTagDefault.where.not(id: @wechat_tags.where(tagging_type: 'WechatTagDefault').pluck(:tagging_id))
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
    @wechat_tag.destroy
    redirect_to admin_wechat_app_wechat_tags_url(@wechat_app)
  end

  private
  def set_wechat_tag
    @wechat_tag = @wechat_app.wechat_tags.find(params[:id])
  end

  def wechat_tag_params
    p = params.fetch(:wechat_tag, {}).permit(
      :name,
      :tagging_id
    )
    p.merge! tagging_type: 'WechatTagDefault' if params[:tagging_type].blank?
    p
  end

end
