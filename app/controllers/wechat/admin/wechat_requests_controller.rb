class Wechat::Admin::WechatRequestsController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_request, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit('created_at-gte', 'created_at-lte')
    if q_params['created_at-lte']
      q_params['created_at-lte'] = q_params['created_at-lte'].to_time.end_of_day
    end
    @wechat_requests = @wechat_app.wechat_requests.default_where(q_params).order(id: :desc).page(params[:page])
  end

  def show
  end

  def update
    @wechat_request.assign_attributes(wechat_request_params)

    unless @wechat_request.save
      render :update, locals: { model: @wechat_request }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_request.destroy
  end

  private
  def set_wechat_request
    @wechat_request = @wechat_app.wechat_requests.find(params[:id])
  end

end
