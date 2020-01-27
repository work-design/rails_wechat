class Wechat::Admin::WechatRepliesController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_reply, only: [:show, :edit, :edit_news, :update, :destroy]

  def index
    q_params = {}
    @wechat_replies = @wechat_app.wechat_replies.default_where(q_params).page(params[:page])
  end

  def new
    @wechat_reply = @wechat_app.wechat_replies.build
  end

  def create
    @wechat_reply = @wechat_app.wechat_replies.build(wechat_reply_params)

    unless @wechat_reply.save
      render :new, locals: { model: @wechat_reply }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def edit_news
  end

  def update
    @wechat_reply.assign_attributes(wechat_reply_params)

    unless @wechat_reply.save
      render :edit, locals: { model: @wechat_reply }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_reply.destroy
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.find params[:wechat_app_id]
  end

  def set_wechat_reply
    @wechat_reply = @wechat_app.wechat_replies.find(params[:id])
  end

  def wechat_reply_params
    params.fetch(:wechat_reply, {}).permit(
      :type,
      :title,
      :description,
      :value,
      :body,
      news_reply_items_attributes: {}
    )
  end

end
