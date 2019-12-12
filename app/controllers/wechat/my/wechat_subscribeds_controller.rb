class Wechat::My::WechatSubscribedsController < Wechat::My::BaseController
  before_action :set_wechat_subscribed, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_subscribeds = WechatSubscribed.page(params[:page])
  end

  def new
    @wechat_subscribed = WechatSubscribed.new
  end

  def create
    @wechat_subscribed = WechatSubscribed.new(wechat_subscribed_params)

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
  def set_wechat_subscribed
    @wechat_subscribed = WechatSubscribed.find(params[:id])
  end

  def wechat_subscribed_params
    params.fetch(:wechat_subscribed, {}).permit(
      :template_id,
      :status,
      :sending_at
    )
  end

end
