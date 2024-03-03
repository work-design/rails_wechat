# Should order after RailsAuth::Application
module Wechat
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_wechat_app, :current_js_app, :current_corp_user
    end

    def require_user(app = current_oauth_app)
      wechat_oauth_options = {
        port: request.port,
        protocol: request.protocol
      }
      wechat_oauth_options.merge! scope: params[:scope] if params[:scope] == 'snsapi_base'

      if request.variant.include?(:work_wechat)
        return if current_user && current_corp_user

        if app.respond_to?(:oauth2_url)
          url = app.oauth2_url(state: urlsafe_encode64(destroyable: false), **wechat_oauth_options)
        end
      elsif request.variant.include?(:mini_program)
        check_jwt_token if params[:auth_jwt_token]
        return if current_wechat_user && current_user
        render 'require_program_login', layout: 'raw', locals: { path: 'state_return', state: urlsafe_encode64(destroyable: false) } and return
      elsif request.variant.include?(:wechat) && app
        return if current_wechat_user && current_user

        if app.respond_to?(:oauth2_url)
          url = app.oauth2_url(state: urlsafe_encode64(destroyable: false), **wechat_oauth_options)
        end
      elsif app
        return if current_user

        if request.variant.exclude?(:phone)
          url = url_for(controller: '/wechat/wechat', action: 'login', identity: params[:identity])
        end
      end

      if defined?(url) && url
        logger.debug "\e[35m  Redirect to: #{url}  \e[0m"
        if request.get?
          redirect_to url, allow_other_host: true and return
        else
          render 'visit', locals: { url: url } and return
        end
      end

      super
    end

    def current_oauth_app
      return @current_oauth_app if defined? @current_oauth_app
      if request.variant.include?(:work_wechat)
        @current_oauth_app = current_organ.corps.where.not(agentid: nil).take
      else
        @current_oauth_app = current_organ&.app
      end

      logger.debug "\e[35m  Current Oauth App: #{@current_oauth_app&.base_class_name}/#{@current_oauth_app&.id}  \e[0m"
      @current_oauth_app
    end

    def current_provider_app
      return @current_provider_app if defined? @current_provider_app
      @current_provider_app = current_organ.provider&.app

      logger.debug "\e[35m  Current Admin Oauth App: #{@current_provider_app&.base_class_name}/#{@current_provider_app&.id}  \e[0m"
      @current_provider_app
    end

    def current_js_app
      return @current_js_app if defined?(@current_js_app)
      if request.variant.include?(:work_wechat)
        @current_js_app = current_corp_user&.corp
      else
        @current_js_app = current_organ.app
      end

      logger.debug "\e[35m  Current Js App: #{@current_js_app&.id}  \e[0m"
      @current_js_app
    end

    def current_wechat_app
      return @current_wechat_app if defined?(@current_wechat_app)
      @current_wechat_app = current_wechat_user&.app || PublicApp.global.take

      logger.debug "\e[35m  Current Wechat App: #{@current_wechat_app&.id}  \e[0m"
      @current_wechat_app
    end

    def current_payee
      return @current_payee if defined?(@current_payee)
      @current_payee = current_organ_domain.payees.take
      logger.debug "\e[35m  Current Payee: #{@current_payee&.id}  \e[0m"
      @current_payee
    end

    def current_wechat_user
      return @current_wechat_user if defined?(@current_wechat_user)
      @current_wechat_user = current_authorized_token&.oauth_user
      if @current_wechat_user
        if request.variant.include?(:mini_program) && current_user
          appid = request.user_agent&.scan(RegexpUtil.between('miniProgram/', '$')).presence || request.referer&.scan(RegexpUtil.between('servicewechat.com/', '/')).presence || current_authorized_token.appid
          @current_wechat_user.same_oauth_users.where(appid: appid).take
        elsif request.variant.include?(:wechat) && current_user
          wechat_appids = (PublicApp.global + PublicApp.default_where(default_ancestors_params)).pluck(:appid).uniq
          @current_wechat_user.same_oauth_users.where(appid: wechat_appids).take
        end
      end
      logger.debug "\e[35m  Current Wechat User: #{@current_wechat_user&.id}  \e[0m"
      @current_wechat_user
    end

    def current_corp_user
      return unless current_authorized_token
      return @current_corp_user if defined? @current_corp_user
      @current_corp_user = current_authorized_token.corp_user

      logger.debug "\e[35m  Login as Corp User: #{@current_corp_user&.id}  \e[0m"
      @current_corp_user
    end

    def login_by_oauth_user(oauth_user, url: url_for(controller: '/home'))
      state = Com::State.find_by(id: params[:state])
      @current_authorized_token = oauth_user.authorized_token
      @current_user = oauth_user.user
      logger.debug "\e[35m  Login by OauthUser #{oauth_user.id} as user: #{current_user&.id}  \e[0m"

      if state
        state.update user_id: oauth_user.user_id, auth_token: oauth_user.auth_token, destroyable: true
        render 'state_visit', layout: 'raw', locals: { state: state }
      else
        redirect_to url_for(controller: '/home', auth_jwt_token: oauth_user.auth_jwt_token), allow_other_host: true
      end
    end

    def login_by_corp_user(corp_user, url: url_for(controller: '/home'))
      state = Com::State.find_by(id: params[:state])
      @current_authorized_token = corp_user.authorized_token

      logger.debug "\e[35m  Login by CorpUser #{corp_user.id}  \e[0m"

      if state
        render 'state_visit', layout: 'raw', locals: { state: state, auth_token: current_authorized_token.id }
      else
        render 'visit', layout: 'raw', locals: { url: url }
      end
    end

    def bind_to_wechat(request)
      key = request[:EventKey].delete_prefix?('qrscene_')
      wechat_user = WechatUser.find_by(open_id: request[:FromUserName])
      session[:wechat_open_id] ||= request[:FromUserName]

      user = User.find_by id: key
      if wechat_user && user
        old_user = wechat_user.user
        if old_user&.id == user.id
          request.reply.text "您的微信账号已经绑定到账号 #{user.member_name} 了"
        elsif old_user
          wechat_user.update(user_id: key, state: :change_bind)
          request.reply.text "您的微信账号已更换绑定账号, 之前绑定的账号是#{old_user.member_name}, 已经绑定到#{user.member_name}"
        else
          wechat_user.update(user_id: key, state: :bind)
          request.reply.text "您的微信账号绑定至账号 #{user.member_name} 成功"
        end
      elsif user
        user.wechat_users.create(open_id: request[:FromUserName], state: :bind)
        request.reply.text "已成功绑定,账号 #{user.member_name}"
      else
        request.reply.text '未找到当前用户,绑定失败'
      end
    end

  end
end
