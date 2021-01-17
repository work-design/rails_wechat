module Wechat
  class My::WechatUsersController < My::BaseController
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

    def show
    end

    def edit
    end

    def update
      @wechat_user.assign_attribute wechat_user_params

      if @wechat_user.save
        redirect_to wechat_users_url
      else
        render :edit
      end
    end

    def destroy
      @wechat_user.destroy
    end

    private
    def set_wechat_user
      current_wechat_user
    end

    def wechat_user_params
      params.fetch(:wechat_user, {}).permit(
        :remark
      )
    end

  end
end
