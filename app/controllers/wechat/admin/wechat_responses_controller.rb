class Wechat::Admin::WechatResponsesController < Wechat::Admin::BaseController
  before_action :set_wechat_config
  before_action :set_wechat_response, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_responses = @wechat_config.wechat_responses.page(params[:page])
  end

  def new
    @wechat_response = @wechat_config.wechat_responses.build
  end

  def create
    @wechat_response = @wechat_config.wechat_responses.build(wechat_response_params)

    respond_to do |format|
      if @wechat_response.save
        format.html.phone
        format.html { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
        format.js { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
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
        format.html { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
        format.js { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_to admin_wechat_config_wechat_responses_url(@wechat_config) }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_response.destroy
    redirect_to admin_wechat_config_wechat_responses_url(@wechat_config)
  end

  private
  def set_wechat_config
    @wechat_config = WechatConfig.find params[:wechat_config_id]
  end
  
  def set_wechat_response
    @wechat_response = WechatResponse.find(params[:id])
  end

  def wechat_response_params
    params.fetch(:wechat_response, {}).permit(
      :regexp,
      :response
    )
  end

end
