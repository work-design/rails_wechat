module Wechat
  class WechatsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false
    before_action :set_app
    before_action :verify_signature

    def show
      if @app.is_a?(WechatWork)
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @app.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      r = Hash.from_xml(request.raw_post).fetch('xml', {})
      @wechat_received = @app.wechat_receiveds.build
      if r['Encrypt']
        @wechat_received.encrypt_data = r['Encrypt']
      else
        @wechat_received.message_hash = r
      end
      @wechat_received.save
      request = @wechat_received.reply

      render plain: request.to_wechat
    end

    private
    def set_app
      @app = App.valid.find(params[:id])
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
