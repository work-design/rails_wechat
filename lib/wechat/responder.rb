require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    MSG_TYPE = [
      :text, :image, :voice, :video, :shortvideo, :location, :link, :event # 消息类型
    ].freeze
    WITH_TYPE = [:text, :event].freeze
    
    included do
      skip_before_action :verify_authenticity_token, raise: false

      before_action :set_wechat_app, only: [:show, :create]
      before_action :verify_signature, only: [:show, :create]
    end
    
    def show
      if @wechat_app.is_a?(WechatWork)
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @wechat_app.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      received = Wechat::Message::Received.from_controller(self)
      replied = received.response
      
      if replied.respond_to? :to_xml
        render plain: replied.to_xml
      else
        head :ok, content_type: 'text/html'
      end
      
      ActiveSupport::Notifications.instrument 'wechat.responder.after_create', request: received.to_xml, response: replied&.to_xml
    end

    private
    def set_wechat_app
      @wechat_app = WechatApp.valid.find(params[:id])
    end

    def verify_signature
      if @wechat_app
        msg_encrypt = nil
        #msg_encrypt = params[:echostr] || request_encrypt_content if @wechat_app.encrypt_mode
        signature = params[:signature] || params[:msg_signature]

        forbidden = (signature != Signature.hexdigest(@wechat_app.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        forbidden = true
      end
      
      render plain: 'Forbidden', status: 403 if forbidden
    end

    module ClassMethods
      attr_reader :configs
      
      def on(msg_type, event: nil, with: nil, &block)
        @configs ||= []
        raise 'Unknown message type' unless MSG_TYPE.include?(msg_type)
        config = { msg_type: msg_type }
        config[:proc] = block if block_given?

        if msg_type == :event
          if event
            config[:event] = event
          else
            raise 'Must appoint event type'
          end
        end
    
        if with.present?
          unless WITH_TYPE.include?(msg_type)
            warn "Only #{WITH_TYPE.join(', ')} can having :with parameters", uplevel: 1
          end
      
          case with
          when String, Regexp
            config[:with] = with
          else
            raise 'With is only support String or Regexp!'
          end
        end
    
        @configs << config
        config
      end

    end


  end
end
