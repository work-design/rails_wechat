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
      @oauth_user.save

      login_by_oauth_user(@oauth_user)
    end

    def qrcode
      r = @app.api.get_wxacode(params[:path])
      send_data r.read
    end

    def confirm
      @app = App.find_by(confirm_name: params[:path])

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
        if @app.is_a?(WorkApp) && params[:echostr].present?
          msg_encrypt = params[:echostr]
        elsif @app.is_a?(WorkApp) && ['POST'].include?(request.request_method)
          r = Hash.from_xml(request.raw_post).fetch('xml', {})
          msg_encrypt = r['Encrypt']
        else
          msg_encrypt = nil
        end
        # msg_signature 为企业微信的参数名
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
