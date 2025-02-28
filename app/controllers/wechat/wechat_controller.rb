module Wechat
  class WechatController < BaseController
    skip_before_action :verify_authenticity_token if whether_filter(:verify_authenticity_token)
    before_action :clear_auth_token, only: [:login]
    layout 'auth/base', only: [:login, :admin_login]

    def auth
      @wechat_user = WechatUser.find_or_initialize_by(uid: params[:openid])
      @wechat_user.assign_attributes params.permit(:access_token, :refresh_token, :app_id)
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
      @scene = current_oauth_app.scenes.find_or_initialize_by(match_value: "session_#{session.id}@#{params[:state]}")
      @scene.expire_seconds = 600 # 默认 600 秒有效
      @scene.check_refresh(true)
      @scene.aim = 'login'
      @scene.save
    end

    def admin_login
      if request.subdomain == 'admin'
        app = App.global.take
      else
        app = current_provider_app
      end

      @scene = app.scenes.find_or_initialize_by(match_value: "session_#{session.id}@#{request.base_url}")
      @scene.expire_seconds = 600 # 默认 600 秒有效
      @scene.check_refresh(true)
      @scene.aim = 'login'
      @scene.save

      render :login
    end

    def launch
      head :ok
    end

    def js
      session[:enter_url] = params[:url] if params[:url].present?
      if params[:appid].present?
        js_app = App.find_by appid: params[:appid]
      else
        js_app = current_js_app
      end

      if js_app
        options = js_app.js_config(session[:enter_url])
        render json: {
          debug: js_app.debug,
          apis: [
            'scanQRCode', 'chooseWXPay',
            'openUserProfile', 'shareToExternalMoments',
            'openAddress', 'getLocation', 'openLocation',
            'chooseImage', 'previewImage', 'uploadImage',
            'updateTimelineShareData', 'updateAppMessageShareData'
          ],
          open_tags: ['wx-open-subscribe'],
          **options
        }
      else
        render json: {}
      end
    end

    def agent_js
      session[:enter_url] = params[:url] if params[:url].present?
      if params[:appid].present?
        js_app = Corp.find_by appid: params[:appid]
      else
        js_app = current_js_app
      end

      if js_app
        r = js_app.agent_config(session[:enter_url])
        logger.debug "\e[35m  agent config: #{r}  \e[0m"
        render json: {
          debug: js_app.debug,
          apis: [
            'selectExternalContact', 'openUserProfile'
          ],
          **r
        }
      else
        render json: {}
      end
    end

    def friend
      render :friend, layout: 'my'
    end

    private
    def login_by_wechat_user(oauth_user)
      headers['Authorization'] = oauth_user.account.auth_token
      oauth_user.user.update(last_login_at: Time.current)

      logger.debug "\e[35m  Login by oauth user as user: #{oauth_user.user_id}  \e[0m"
      @current_oauth_user = oauth_user
      @current_user = oauth_user.user
    end

    def clear_auth_token
      @current_authorized_token = nil
      session.delete :auth_token
    end

  end
end
