class Wechat::My::WechatSubscribedsController < Wechat::My::BaseController
  before_action :set_wechat_subscribed, only: [:show, :edit, :update, :destroy]
  before_action :set_wechat_template, only: [:create]
  
  def index
    @wechat_subscribeds = WechatSubscribed.page(params[:page])
  end

  def new
    @wechat_subscribed = WechatSubscribed.new
  end

  def create
    @wechat_subscribed = current_wechat_user.wechat_subscribeds.build(wechat_subscribed_params)
    @wechat_subscribed.wechat_template = @wechat_template
    
    unless @wechat_subscribed.save
      render :new, locals: { model: @wechat_subscribed }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_subscribed.assign_attributes(wechat_subscribed_params)

    unless @wechat_subscribed.save
      render :edit, locals: { model: @wechat_subscribed }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_subscribed.destroy
  end

  private
  def set_wechat_template
    @wechat_template = current_wechat_user.wechat_app.wechat_templates.find_by template_id: params[:template_id]
  end
  
  def set_wechat_subscribed
    @wechat_subscribed = WechatSubscribed.find(params[:id])
  end

  def wechat_subscribed_params
    params.fetch(:wechat_subscribed, {}).permit(
      :status,
      :sending_at
    )
  end

end
