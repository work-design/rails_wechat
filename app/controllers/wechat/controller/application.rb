# Should order after RailsAuth::Application
module Wechat
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_wechat_app, :current_js_app, :current_corp_user
    end

    def require_login(return_to: nil)
      return if current_user
      return super unless request.variant.any?(:wechat)
      store_location(return_to)

      if current_wechat_user && current_wechat_user.user.nil?
        redirect_url = url_for(controller: '/auth/sign', action: 'sign', uid: current_wechat_user.uid)
      elsif current_oauth_app && current_oauth_app.respond_to?(:oauth2_url)
        redirect_url = current_oauth_app.oauth2_url(host: request.host, port: request.port, protocol: request.protocol)
      else
        redirect_url = url_for(controller: '/auth/sign', action: 'sign')
      end

      if redirect_url
        logger.debug "\e[35m  Redirect to: #{redirect_url}  \e[0m"
      end

      if request.format.html?
        render 'require_login', locals: { url: redirect_url }, layout: 'raw', status: 401
      else
        render 'require_login', locals: { url: redirect_url }, status: 401
      end
    end

    def current_oauth_app
      return @current_oauth_app if defined? @current_oauth_app
      if request.user_agent =~ /wxwork/
        @current_oauth_app = Suite.first
      else
        @current_oauth_app = current_organ_domain&.wechat_app
      end

      logger.debug "\e[35m  Current Oauth App is #{@current_oauth_app&.class_name}/#{@current_oauth_app&.id}  \e[0m"
      @current_oauth_app
    end

    def current_js_app
      return @current_js_app if defined?(@current_js_app)
      if request.user_agent =~ /wxwork/ && current_account
        @current_js_app = current_account.corp_users[0]&.corp
      else
        @current_js_app = current_organ_domain&.wechat_app
      end

      logger.debug "\e[35m  Current Js App is #{@current_js_app&.id}  \e[0m"
      @current_js_app
    end

    def current_wechat_app
      return @current_wechat_app if defined?(@current_wechat_app)
      @current_wechat_app = current_organ_domain&.wechat_app || App.global.take

      logger.debug "\e[35m  Current Wechat App is #{@current_wechat_app&.id}  \e[0m"
      @current_wechat_app
    end

    def current_wechat_user
      return @current_wechat_user if defined?(@current_wechat_user)
      @current_wechat_user = current_account&.wechat_user
    end

    def current_corp_user
      return @current_corp_user if defined? @current_corp_user
      if current_account.respond_to? :corp_users
        @current_corp_user = current_account.corp_users[0]
      else
        @current_corp_user = nil
      end
    end

    # 需要微信授权获取openid, 但并不需要注册为用户
    def require_wechat_user(return_to: nil)
      return if current_oauth_user
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
