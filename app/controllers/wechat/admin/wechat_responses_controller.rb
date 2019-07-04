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

    respond_to do |format|
      if @wechat_response.save
        format.html.phone
        format.html { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.js { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.json { render :show }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_response.assign_attributes(wechat_response_params)

    respond_to do |format|
      if @wechat_response.save
        format.html.phone
        format.html { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.js { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_to admin_wechat_app_wechat_responses_url(@wechat_app) }
        format.json { render :show }
      end
    end
  end

  def sync
    r= Wechat.api(@wechat_app.account).menu_create @wechat_app.menu
    redirect_to admin_wechat_app_wechat_menus_url(@wechat_app), notice: r.to_s
  end

  def destroy
    @wechat_response.destroy
    redirect_to admin_wechat_app_wechat_responses_url(@wechat_app)
  end

  private
  def set_wechat_response
    @wechat_response = @wechat_app.wechat_responses.find(params[:id])
  end

  def wechat_response_params
    params.fetch(:wechat_response, {}).permit(
      :type,
      :match_value,
      :expire_seconds,
      :start_at,
      :finish_at,
      :valid_response,
      :invalid_response
    )
  end

end
