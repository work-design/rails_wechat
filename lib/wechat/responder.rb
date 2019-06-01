require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    
    WITH_TYPE = [:text, :event, :click, :view, :scan, :batch_job].freeze
    MUST_WITH = [:click, :view, :scan, :batch_job].freeze
    
    included do
      skip_before_action :verify_authenticity_token, raise: false

      before_action :set_wechat_config, only: [:show, :create]
      before_action :verify_signature, only: [:show, :create]
    end
    
    def show
      if @wechat_config.is_a?(WechatWork)
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @wechat_config.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      received = Wechat::Message::Received.new(@wechat_config, request.raw_post)
      binding.pry
      replied = received.reply

      if respond.respond_to? :to_xml
        render plain: replied.to_xml
      else
        head :ok, content_type: 'text/html'
      end
      
      ActiveSupport::Notifications.instrument 'wechat.responder.after_create', request: request_msg, response: response_msg
    end

    private
    def set_wechat_config
      @wechat_config = WechatConfig.valid.find_by(account: params[:id])
    end

    def verify_signature
      if @wechat_config
        msg_encrypt = nil
        #msg_encrypt = params[:echostr] || request_encrypt_content if @wechat_config.encrypt_mode
        signature = params[:signature] || params[:msg_signature]

        forbidden = (signature != Signature.hexdigest(@wechat_config.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        forbidden = true
      end
      
      render plain: 'Forbidden', status: 403 if forbidden
    end

    def run_responder(message)
      self.class.responder_for(message) do |responder, *args|
        responder ||= self.class.user_defined_responders(:fallback).first

        next if responder.nil?
        case
        when responder[:respond]
          request.reply.text responder[:respond]
        when responder[:proc]
          responder[:proc].call(message, *args)
        else
          next
        end
      end
    end

    module ClassMethods
  
      def on(msg_type, event: nil, with: nil, &block)
        raise 'Unknown message type' unless MESSAGE_TYPE.include?(message_type)
        config = { msg_type: msg_type }
        config[:proc] = block if block_given?
    
        if with.present?
          unless WITH_TYPE.include?(message_type)
            warn "Only #{WITH_TYPE.join(', ')} can having :with parameters", uplevel: 1
          end
      
          case with
          when String
            config[:with_string] = with
          when Regexp
            config[:with_regexp] = with
          else
            raise 'With is only support String or Regexp!'
          end
        else
          raise "Message type #{MUST_WITH.join(', ')} must specify :with parameters" if MUST_WITH.include?(message_type)
        end
    
        if msg_type == :event
          config[:event] = event
        end
    
        @configs << config
        config
      end

    end


  end
end
