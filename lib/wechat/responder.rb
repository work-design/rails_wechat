require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    include Wechat::ControllerApi
    
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
      message = Wechat::Message::Received.from_hash(post_xml)
      respond = run_responder(message)

      if respond.respond_to? :to_xml
        render plain: process_response(respond)
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
        msg_encrypt = params[:echostr] || request_encrypt_content if @wechat_config.encrypt_mode
        signature = params[:signature] || params[:msg_signature]

        forbidden = (signature != Signature.hexdigest(@wechat_config.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        forbidden = true
      end
      
      render plain: 'Forbidden', status: 403 if forbidden
    end

    def post_xml
      request_content = params[:xml].nil? ? Hash.from_xml(request.raw_post) : { 'xml' => params[:xml] }
      data = request_content.dig('xml', 'Encrypt')

      if @wechat_config.encrypt_mode && request_encrypt_content.present?
        content, @we_app_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(request_encrypt_content), @wechat_config.encoding_aes_key))
        data = Hash.from_xml(content)
      end

      data_hash = data.fetch('xml', {})
      data_hash = data_hash.to_unsafe_hash if data_hash.instance_of?(ActionController::Parameters)
      HashWithIndifferentAccess.new(data_hash).tap do |msg|
        msg[:Event].downcase! if msg[:Event]
      end
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

    def process_response(response)
      if response[:MsgType] == 'success'
        msg = 'success'
      else
        msg = response.to_xml
      end

      if @wechat_config.encrypt_mode
        encrypt = Base64.strict_encode64(Cipher.encrypt(Cipher.pack(msg, @we_app_id), @wechat_config.encoding_aes_key))
        msg = generate_msg(encrypt, params[:timestamp], params[:nonce])
      end

      msg
    end

    def generate_msg(encrypt, timestamp, nonce)
      msg_sign = Signature.hexdigest(@wechat_config.token, timestamp, nonce, encrypt)

      {
        Encrypt: encrypt,
        MsgSignature: msg_sign,
        TimeStamp: timestamp,
        Nonce: nonce
      }.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    end
    
  end
end
