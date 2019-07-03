class Wechat::Admin::WechatTagsController < Wechat::Admin::BaseController
  before_action :set_wechat_tag, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! organ_ancestors_params
    if q_params[:organ_id]
      q_params[:organ_id] = Array(q_params[:organ_id]) + [nil]
    end
    @wechat_tags = WechatTag.default_where(q_params).page(params[:page])
  end

  def new
    @wechat_tag = WechatTag.new
  end

  def create
    @wechat_tag = WechatTag.new(wechat_tag_params)

    respond_to do |format|
      if @wechat_tag.save
        format.html.phone
        format.html { redirect_to admin_wechat_tags_url }
        format.js { redirect_back fallback_location: admin_wechat_tags_url }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_wechat_tags_url }
        format.json { render :show }
      end
    end
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
        format.html { redirect_to admin_wechat_tags_url }
        format.js { redirect_back fallback_location: admin_wechat_tags_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_tags_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_tag.destroy
    redirect_to admin_wechat_tags_url
  end

  private
  def set_wechat_tag
    @wechat_tag = WechatTag.find(params[:id])
  end

  def wechat_tag_params
    p = params.fetch(:wechat_tag, {}).permit(
      :name,
      :tag_name
    )
    p.merge! default_params
  end

end
