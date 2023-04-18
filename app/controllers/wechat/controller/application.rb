# Should order after RailsAuth::Application
module Wechat
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_wechat_app, :current_js_app, :current_corp_user
    end

    def require_user(return_to: nil)
      if request.variant.include?(:work_wechat)
        return if current_user && current_corp_user
      else
        return if current_user && current_wechat_user
      end
      return super if request.variant.include?(:mini_program) || request.variant.exclude?(:wechat)

      if current_wechat_user && current_wechat_user.user.nil?
        store_location(return_to)
        redirect_url = url_for(controller: '/auth/sign', action: 'sign', uid: current_wechat_user.uid)
      elsif current_oauth_app.oauth_enable && current_oauth_app.respond_to?(:oauth2_url)
        redirect_url = current_oauth_app.oauth2_url(state: urlsafe_encode64(destroyable: false), port: request.port, protocol: request.protocol)
      else
        redirect_url = url_for(controller: '/auth/sign', action: 'sign')
      end

      if redirect_url
        logger.debug "\e[35m  Redirect to: #{redirect_url}  \e[0m"
        render 'require_user', layout: 'raw', locals: { url: redirect_url }
      end
    end

    def current_oauth_app
      return @current_oauth_app if defined? @current_oauth_app
      if request.variant.include?(:work_wechat)
        @current_oauth_app = WorkApp.default_where(default_ancestors_params).take || WorkApp.global.take
      else
        @current_oauth_app = PublicApp.global.take
      end

      logger.debug "\e[35m  Current Oauth App: #{@current_oauth_app&.class_name}/#{@current_oauth_app&.id}  \e[0m"
      @current_oauth_app
    end

    def current_js_app
      return @current_js_app if defined?(@current_js_app)
      if request.variant.include?(:work_wechat) && current_account
        @current_js_app = current_corp_user&.corp
      else
        @current_js_app = PublicApp.default_where(default_params).take || PublicApp.global.take
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

      if params[:appid]
        @current_payee = current_organ_domain.app_payees.enabled.find_by(appid: params[:appid])
      elsif current_wechat_app
        @current_payee = current_organ_domain.app_payees.enabled.find_by(appid: current_wechat_app.appid)
      else
        @current_payee = current_organ_domain.app_payees.take
      end

      logger.debug "\e[35m  Current Payee: #{@current_payee&.id}  \e[0m"
      @current_payee
    end

    def current_wechat_user
      return unless current_account
      return @current_wechat_user if defined?(@current_wechat_user)

      if request.variant.include?(:wechat) && request.variant.exclude?(:mini_program)
        r = current_authorized_token.oauth_user
        if r.is_a?(Wechat::ProgramUser) || r.nil?
          @current_wechat_user = current_user.wechat_users.unscope(where: :type).find_by(type: 'Wechat::WechatUser')
        end
        @current_wechat_user = r if @current_wechat_user.nil?
      else
        @current_wechat_user = current_user.wechat_users.find_by(type: 'Wechat::ProgramUser')
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

    # 需要微信授权获取openid, 但并不需要注册为用户
    def require_wechat_user(return_to: nil)
      return if current_wechat_user
      store_location(return_to)

      redirect_url = '/auth/wechat?skip_register=true'

      render 'wechat_require_login', locals: { redirect_url: redirect_url, message: '请允许获取您的微信信息' }, status: 401
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
