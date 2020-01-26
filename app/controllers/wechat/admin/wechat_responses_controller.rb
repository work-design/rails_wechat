class Wechat::Admin::WechatResponsesController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_response, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {
      type: ['TextResponse', 'PersistScanResponse']
    }
    q_params.merge! params.permit(:type)
    @wechat_responses = @wechat_app.wechat_responses.default_where(q_params).order(id: :desc).page(params[:page])
  end

  def new
    @wechat_response = @wechat_app.wechat_responses.build
  end

  def create
    @wechat_response = @wechat_app.wechat_responses.build(wechat_response_params)

    unless @wechat_response.save
      render :new, locals: { model: @wechat_response }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_response.assign_attributes(wechat_response_params)

    unless @wechat_response.save
      render :edit, locals: { model: @wechat_response }, status: :unprocessable_entity
    end
  end

  def sync
    r= Wechat.api(@wechat_app.account).menu_create @wechat_app.menu
    redirect_to admin_wechat_app_wechat_menus_url(@wechat_app), notice: r.to_s
  end

  def destroy
    @wechat_response.destroy
  end

  private
  def set_wechat_response
    @wechat_response = @wechat_app.wechat_responses.find(params[:id])
  end

  def wechat_response_params
    params.fetch(:wechat_response, {}).permit(
      :type,
      :match_value,
      :contain,
      :default_response,
      :expire_seconds,
      :start_at,
      :finish_at
    )
  end

end
