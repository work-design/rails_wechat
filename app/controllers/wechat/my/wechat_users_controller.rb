module Wechat
  class My::WechatUsersController < My::BaseController
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

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
