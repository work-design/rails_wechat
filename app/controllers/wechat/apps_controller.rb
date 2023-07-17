module Wechat
  class AppsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_app, only: [:show, :create, :login, :bind, :qrcode]
    before_action :set_scene, only: [:login]
    before_action :verify_signature, only: [:show, :create]

    def show
      render plain: params[:echostr]
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

      if @oauth_user.save
        login_by_oauth_user(@oauth_user)
      else
        logger.debug @oauth_user.error_text
      end
    end

    def qrcode
      r = @app.api.get_wxacode(params[:path])
      send_data r.read
    end

    def confirm
      if params[:path].start_with?('WW_verify_')
        @app = Agent.find_by(confirm_name: params[:path])
      else
        @app = App.find_by(confirm_name: params[:path]) || Agency.find_by(confirm_name: params[:path])
      end

      if @app
        render plain: @app.confirm_content
      else
        head :no_content
      end
    end

    private
    def set_app
      @app = App.enabled.find params[:id]
    end

    def verify_signature
      if @app
        msg_encrypt = nil
        forbidden = (params[:signature] != Wechat::Signature.hexdigest(@app.token, params[:timestamp], params[:nonce], msg_encrypt))
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
