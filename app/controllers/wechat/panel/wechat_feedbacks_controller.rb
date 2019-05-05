class Wechat::Panel::WechatFeedbacksController < Wechat::Panel::BaseController
  before_action :set_wechat_config
  before_action :set_wechat_feedback, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_feedbacks = @wechat_config.wechat_feedbacks.page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    @wechat_feedback.assign_attributes(wechat_feedback_params)

    respond_to do |format|
      if @wechat_feedback.save
        format.html.phone
        format.html { redirect_to panel_wechat_config_wechat_feedbacks_url(@wechat_config) }
        format.js { redirect_to panel_wechat_config_wechat_feedbacks_url(@wechat_config) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: panel_wechat_feedbacks_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_feedback.destroy
    redirect_to panel_wechat_config_wechat_feedbacks_url(@wechat_config)
  end

  private
  def set_wechat_config
    @wechat_config = WechatConfig.find params[:wechat_config_id]
  end
  
  def set_wechat_feedback
    @wechat_feedback = WechatFeedback.find(params[:id])
  end

  def wechat_feedback_params
    params.fetch(:wechat_feedback, {}).permit(
      :wechat_user_id,
      :body,
      :feedback_on,
      :kind
    )
  end

end
