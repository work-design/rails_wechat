module Wechat
  class WechatController < BaseController
    skip_before_action :verify_authenticity_token if whether_filter(:verify_authenticity_token)
    layout 'auth/base', only: [:login]

    def auth
      @wechat_user = WechatUser.find_or_initialize_by(uid: params[:openid])
      @wechat_user.assign_attributes params.permit(:access_token, :refresh_token, :app_id)
      @wechat_user.sync_user_info
      @wechat_user.account = current_account if current_account
      @wechat_user.save

      if @wechat_user.user
        login_by_wechat_user(@wechat_user)
        render 'auth'
      else
        render json: { oauth_user_id: @wechat_user.id }
      end
    end

    def login
      @scene = current_wechat_app.scenes.find_or_initialize_by(match_value: "session_#{session.id}@#{request.base_url}")
      @scene.aim = 'login'
      @scene.expire_seconds ||= 600 # 默认600秒有效
      @scene.save
    end

    def friend
      render :friend, layout: 'my'
    end

    private
    def login_by_wechat_user(oauth_user)
      headers['Authorization'] = oauth_user.account.auth_token
      oauth_user.user.update(last_login_at: Time.current)

      logger.debug "Login by oauth user as user: #{oauth_user.user_id}"
      @current_oauth_user = oauth_user
      @current_user = oauth_user.user
    end

  end
end
