class Wechat::Admin::WechatUsersController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_users = @wechat_app.wechat_users.page(params[:page])
  end

  def show
  end

  def edit
    @wechat_tags = @wechat_app.wechat_tags
  end

  def update
    @wechat_user.assign_attributes(wechat_user_params)

    respond_to do |format|
      if @wechat_user.save
        format.html { redirect_to admin_wechat_app_wechat_users_url(@wechat_app) }
        format.js { redirect_to admin_wechat_app_wechat_users_url(@wechat_app) }
        format.json { render :show }
      else
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_users_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_user.destroy
    redirect_to admin_wechat_users_url
  end

  private
  def set_wechat_user
    @wechat_user = WechatUser.find(params[:id])
  end

  def wechat_user_params
    params.fetch(:wechat_user, {}).permit(
      :name,
      :uid,
      :unionid,
      :account_id,
      :user_id,
      wechat_tag_ids: []
    )
  end

end
