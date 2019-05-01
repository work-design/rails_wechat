class Wechat::My::WechatUsersController < Wechat::My::BaseController
  before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

  def show
  end

  def edit
  end

  def update
    if @wechat_user.update(wechat_user_params)
      redirect_to wechat_users_url, notice: 'Wechat user was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wechat_user.destroy
    redirect_to wechat_users_url, notice: 'Wechat user was successfully destroyed.'
  end

  private
  def set_wechat_user
    current_wechat_user
  end

end
