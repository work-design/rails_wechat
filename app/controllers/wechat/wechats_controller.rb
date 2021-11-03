module Wechat
  class WechatsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_app
    before_action :verify_signature

    def show
      if @app.is_a?(WorkApp)
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @app.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      r = Hash.from_xml(request.raw_post).fetch('xml', {})
      @receive = @app.receives.build
      if r['Encrypt']
        @receive.encrypt_data = r['Encrypt']
      else
        @receive.message_hash = r
      end
      @receive.save

      render plain: @receive.request.to_wechat
    end

    private
    def set_app
      @app = App.enabled.find(params[:id])
    end

    def verify_signature
      if @app
        msg_encrypt = nil
        #msg_encrypt = params[:echostr] || request_encrypt_content if @app.encrypt_mode
        signature = params[:signature] || params[:msg_signature]

        forbidden = (signature != Wechat::Signature.hexdigest(@app.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        forbidden = true
      end

      render plain: 'Forbidden', status: 403 if forbidden
    end

  end
end
