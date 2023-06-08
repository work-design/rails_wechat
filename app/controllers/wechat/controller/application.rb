# Should order after RailsAuth::Application
module Wechat
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_wechat_app, :current_js_app, :current_corp_user
    end

    def require_user
      if request.variant.include?(:work_wechat)
        return if current_user && current_corp_user

        if current_oauth_app.respond_to?(:oauth2_url)
          url = current_oauth_app.oauth2_url(state: urlsafe_encode64(destroyable: false), port: request.port, protocol: request.protocol)
        end
      elsif request.variant.include?(:mini_program)
        return if current_wechat_user && current_user
        render 'require_program_login', locals: { url: url_for(state: urlsafe_encode64(destroyable: false)) } and return
      elsif request.variant.include?(:wechat)
        return if current_wechat_user && current_user

        if current_oauth_app.respond_to?(:oauth2_url)
          url = current_oauth_app.oauth2_url(state: urlsafe_encode64(destroyable: false), port: request.port, protocol: request.protocol)
        end
      else
        return if current_user

        if request.variant.exclude?(:phone) && current_wechat_app
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
        @current_oauth_app = Agent.default_where(default_ancestors_params).take
      else
        @current_oauth_app = current_organ.app || PublicApp.global.take
      end

      logger.debug "\e[35m  Current Oauth App: #{@current_oauth_app&.class_name}/#{@current_oauth_app&.id}  \e[0m"
      @current_oauth_app
    end

    def current_js_app
      return @current_js_app if defined?(@current_js_app)
      if request.variant.include?(:work_wechat)
        @current_js_app = current_corp_user&.corp
      else
        @current_js_app = PublicApp.default_where(default_params).take || PublicApp.global.take
      end

      logger.debug "\e[35m  Current Js App: #{@current_js_app&.id}  \e[0m"
      @current_js_app
    end

    def current_wechat_apps
      PublicApp.global + PublicApp.default_where(default_ancestors_params)
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

      if request.variant.include?(:mini_program) && current_user
        appid = request.user_agent&.scan(RegexpUtil.between('miniProgram/', '$')).presence || request.referer&.scan(RegexpUtil.between('servicewechat.com/', '/')).presence
        @current_wechat_user = current_user.wechat_users.where(appid: appid).take
      elsif request.variant.include?(:wechat) && current_user
        @current_wechat_user = current_user.wechat_users.where(appid: current_wechat_apps.pluck(:appid)).take
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
      if state
        state.update user_id: oauth_user.user_id, destroyable: true
      end

      @current_account = oauth_user.account
      #@current_user = oauth_user.user
      @current_authorized_token = oauth_user.authorized_token
      logger.debug "\e[35m  Login by OauthUser #{oauth_user.id} as user: #{current_user&.id}  \e[0m"

      if state
        render 'state_visit', layout: 'raw', locals: { state: state, auth_token: current_authorized_token.id }
      else
        render 'visit', layout: 'raw', locals: { url: url }
      end
    end

    def login_by_corp_user(corp_user, url: url_for(controller: '/home'))
      state = Com::State.find_by(id: params[:state])
      @current_account = corp_user.account
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
