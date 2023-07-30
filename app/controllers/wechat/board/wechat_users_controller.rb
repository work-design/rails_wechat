module Wechat
  class Board::WechatUsersController < Board::BaseController
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @wechat_users = current_user.wechat_users.includes(:app).order(appid: :asc)
    end

    private
    def set_wechat_user
      @wechat_user = WechatUser.find(params[:id])
    end

  end
end
