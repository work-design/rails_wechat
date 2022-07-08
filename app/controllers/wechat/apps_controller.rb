module Wechat
  class AppsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_app, only: [:show, :create, :login, :bind, :qrcode]
    before_action :set_scene, only: [:login]
    before_action :verify_signature, only: [:show, :create]

    def show
      if @app.is_a?(WorkApp)
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @app.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      @receive = @app.receives.build

      if params['ToUserName']
        r = params.permit('Encrypt')
        @receive.msg_format = 'json'
      else
        r = Hash.from_xml(request.raw_post).fetch('xml', {})
      end

      if r['Encrypt']
        @receive.encrypt_data = r['Encrypt']
      else
        @receive.message_hash = r
      end
      @receive.save

      render plain: @receive.request.to_wechat
    end

    def login
      @oauth_user = @app.generate_wechat_user(params[:code])
      if @oauth_user.account.nil? && current_account
        @oauth_user.account = current_account
      end
      @oauth_user.save

      state_hash = Base64.urlsafe_decode64(params[:state]).split('#')

      if @oauth_user.user
        login_by_account(@oauth_user.account)
        Com::SessionChannel.broadcast_to(params[:state], auth_token: current_authorized_token.token)

        url_options = {
          host: state_hash[0],
          controller: state_hash[1],
          action: state_hash[2],
          disposable_token: @oauth_user.account.once_token,
          **state_hash[4].to_s.split('&').map(&->(i){ i.split('=') }).to_h
        }
        url = url_for(**url_options)

        redirect_to url, allow_other_host: true
      else
        url_options = {}
        url_options.merge! params.except(:controller, :action, :id, :business, :namespace, :code, :state).permit!
        url_options.merge! host: state_hash[0]
        url = url_for(controller: 'auth/sign', action: 'bind', uid: @oauth_user.uid, **url_options)

        redirect_to url, allow_other_host: true
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

    private
    def set_app
      @app = App.enabled.find params[:id]
    end

    def verify_signature
      if @app
        msg_encrypt = nil
        msg_encrypt = params[:echostr] || @app.encoding_aes_key if @app.encrypt_mode
        signature = params[:signature] || params[:msg_signature]

        forbidden = (signature != Wechat::Signature.hexdigest(@app.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        forbidden = true
      end

      render plain: 'Forbidden', status: 403 if forbidden
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
