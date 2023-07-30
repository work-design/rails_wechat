module Wechat
  class Board::WechatUsersController < Board::BaseController
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @wechat_users = current_user.wechat_users.includes(:app).order(appid: :asc)
    end

    def create
      @oauth_user = OauthUser.find_or_initialize_by(type: oauth_user_params[:type], uid: oauth_user_params[:uid])
      @oauth_user.save_info(oauth_user_params)
      @oauth_user.init_user

      if @oauth_user.save
        login_by_account @oauth_user.account
        render json: { oauth_user: @oauth_user.as_json, user: @oauth_user.user.as_json }
      end
    end

    def bind
      @oauth_user = OauthUser.find_by(uid: params[:uid])
      @oauth_user.account = current_account

      @oauth_user.save

      redirect_to board_root_url
    end

    private
    def set_wechat_user
      @wechat_user = WechatUser.find(params[:id])
    end

    def oauth_user_params
      params.fetch(:oauth_user, {}).permit(
        :uid,
        :provider,
        :type,
        :name,
        :access_token
      )
    end

  end
end
