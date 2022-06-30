module Wechat
  class AppsController < BaseController
    before_action :set_app, only: [:show, :login, :bind, :qrcode]
    before_action :set_scene, only: [:login]

    def show
      @oauth_user = @app.generate_wechat_user(params[:code])
      if @oauth_user.account.nil? && current_account
        @oauth_user.account = current_account
      end
      @oauth_user.save

      if @oauth_user.user
        login_by_account(@oauth_user.account)
        redirect_to session[:return_to] || RailsAuth.config.default_return_path
        session.delete :return_to
      else
        url_options = {}
        url_options.merge! params.except(:controller, :action, :id, :business, :namespace, :code, :state).permit!
        url_options.merge! host: URI(session[:return_to]).host if session[:return_to]

        redirect_to url_for(controller: 'auth/sign', action: 'sign', uid: @oauth_user.uid, **url_options)
      end
    end

    def login
      @oauth_user = @app.generate_wechat_user(params[:code])
      if @oauth_user.account.nil? && current_account
        @oauth_user.account = current_account
      end
      @oauth_user.save

      if @oauth_user.user
        login_by_account(@oauth_user.account)
        Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.token)

        r = Base64.urlsafe_decode64(params[:state]).split('#')
        url_options = {
          host: r[0],
          controller: r[1],
          action: r[2],
          disposable_token: @oauth_user.account.once_token,
          **r[3].to_s.split('&').map(&->(i){ i.split('=') }).to_h
        }
        url = url_for(**url_options)

        redirect_to url, allow_other_host: true
        #render :login, locals: { url: url }, layout: 'raw'
      else
        url_options = {}
        url_options.merge! params.except(:controller, :action, :id, :business, :namespace, :code, :state).permit!
        url_options.merge! host: params[:state].split('#')[0]
        url = url_for(controller: 'auth/sign', action: 'sign', uid: @oauth_user.uid, **url_options)

        render :login, locals: { url: url }, layout: 'raw'
      end
    end

    # 企业微信账号和微信账号绑定
    def bind
      @oauth_user = @app.generate_wechat_user(params[:code])
      @oauth_user.identity = params[:state]
      @oauth_user.save

      login_by_account(@oauth_user.account)
      url = url_for(controller: 'me/home', host: @oauth_user.account.organs[0]&.host)

      render :bind, locals: { url: url }
    end

    def qrcode
      r = @app.api.get_wxacode(params[:path])
      send_data r.read
    end

    def create
    end

    private
    def set_app
      @app = App.find params[:id]
    end

    def set_scene(prefix = 'invite_form_scan')
      @scene = Scene.find_or_initialize_by(appid: @app.appid, match_value: "#{prefix}")
      @scene.expire_seconds ||= 2592000
      @scene.organ_id = @app.organ_id
      @scene.save
      @scene
    end

  end
end
