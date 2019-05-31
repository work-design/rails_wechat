require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    include Wechat::ControllerApi

    included do
      skip_before_action :verify_authenticity_token, raise: false

      before_action :set_wechat_config, only: [:show, :create]
      before_action :verify_signature, only: [:show, :create]
    end

    module ClassMethods
      def on(message_type, with: nil, respond: nil, &block)
        raise 'Unknow message type' unless [:text, :image, :voice, :video, :shortvideo, :link, :event, :click, :view, :scan, :batch_job, :location, :label_location, :fallback].include?(message_type)
        config = respond.nil? ? {} : { respond: respond }
        config[:proc] = block if block_given?

        if with.present?
          raise 'Only text, event, click, view, scan and batch_job can having :with parameters' unless [:text, :event, :click, :view, :scan, :batch_job].include?(message_type)
          config[:with] = with
          if message_type == :scan
            if with.is_a?(String)
              self.known_scan_key_lists = with
            else
              raise 'on :scan only support string in parameter with, detail see https://github.com/Eric-Guo/wechat/issues/84'
            end
          end
        else
          raise 'Message type click, view, scan and batch_job must specify :with parameters' if [:click, :view, :scan, :batch_job].include?(message_type)
        end

        case message_type
        when :click
          user_defined_click_responders(with) << config
        when :view
          user_defined_view_responders(with) << config
        when :batch_job
          user_defined_batch_job_responders(with) << config
        when :scan
          user_defined_scan_responders << config
        when :location
          user_defined_location_responders << config
        when :label_location
          user_defined_label_location_responders << config
        else
          user_defined_responders(message_type) << config
        end

        config
      end

      def user_defined_click_responders(with)
        @click_responders ||= {}
        @click_responders[with] ||= []
      end

      def user_defined_view_responders(with)
        @view_responders ||= {}
        @view_responders[with] ||= []
      end

      def user_defined_batch_job_responders(with)
        @batch_job_responders ||= {}
        @batch_job_responders[with] ||= []
      end

      def user_defined_scan_responders
        @scan_responders ||= []
      end

      def user_defined_location_responders
        @location_responders ||= []
      end

      def user_defined_label_location_responders
        @label_location_responders ||= []
      end

      def user_defined_responders(type)
        @responders ||= {}
        @responders[type] ||= []
      end

      def responder_for(message)
        message_type = message[:MsgType].to_sym
        responders = user_defined_responders(message_type)

        case message_type
        when :text
          yield(* match_responders(responders, message[:Content]))
        when :event
          if 'click' == message[:Event] && !user_defined_click_responders(message[:EventKey]).empty?
            yield(* user_defined_click_responders(message[:EventKey]), message[:EventKey])
          elsif 'view' == message[:Event] && !user_defined_view_responders(message[:EventKey]).empty?
            yield(* user_defined_view_responders(message[:EventKey]), message[:EventKey])
          elsif 'click' == message[:Event]
            yield(* match_responders(responders, message[:EventKey]))
          elsif known_scan_key_lists.include?(message[:EventKey]) && %w(scan subscribe scancode_push scancode_waitmsg).freeze.include?(message[:Event])
            yield(* known_scan_with_match_responders(user_defined_scan_responders, message))
          elsif 'batch_job_result' == message[:Event]
            yield(* user_defined_batch_job_responders(message[:BatchJob][:JobType]), message[:BatchJob])
          elsif 'location' == message[:Event]
            yield(* user_defined_location_responders, message)
          else
            yield(* match_responders(responders, message[:Event]))
          end
        when :location
          yield(* user_defined_label_location_responders, message)
        else
          yield(responders.first)
        end
      end

      private

      def match_responders(responders, value)
        matched = responders.each_with_object({}) do |responder, memo|
          condition = responder[:with]

          if condition.nil?
            memo[:general] ||= [responder, value]
            next
          end

          if condition.is_a? Regexp
            memo[:scoped] ||= [responder] + $LAST_MATCH_INFO.captures if value =~ condition
          else
            memo[:scoped] ||= [responder, value] if value == condition
          end
        end
        matched[:scoped] || matched[:general]
      end

      def known_scan_with_match_responders(responders, message)
        matched = responders.each_with_object({}) do |responder, memo|
          if %w(scan subscribe).freeze.include?(message[:Event]) && message[:EventKey] == responder[:with]
            memo[:scaned] ||= [responder, message[:Ticket]]
          elsif %w(scancode_push scancode_waitmsg).freeze.include?(message[:Event]) && message[:EventKey] == responder[:with]
            memo[:scaned] ||= [responder, message[:ScanCodeInfo][:ScanResult], message[:ScanCodeInfo][:ScanType]]
          end
        end
        matched[:scaned]
      end

      def known_scan_key_lists
        @known_scan_key_lists ||= []
      end

      def known_scan_key_lists=(qrscene_value)
        @known_scan_key_lists ||= []
        @known_scan_key_lists << qrscene_value
      end
    end

    def show
      if @wechat_config.corpid.present?
        echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @wechat_config.encoding_aes_key))
        render plain: echostr
      else
        render plain: params[:echostr]
      end
    end

    def create
      request_msg = Wechat::Message.from_hash(post_xml)
      response_msg = run_responder(request_msg)

      if response_msg.respond_to? :to_xml
        render plain: process_response(response_msg)
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
        if @wechat_config.encrypt_mode
          msg_encrypt = params[:echostr] || request_encrypt_content
        end
        signature = params[:signature] || params[:msg_signature]

        msg_encrypt = nil unless @wechat_config.corpid.present?
        r = (signature != Signature.hexdigest(@wechat_config.token, params[:timestamp], params[:nonce], msg_encrypt))
      else
        r = true
      end
      
      render plain: 'Forbidden', status: 403 if r
    end

    def post_xml
      data = request_content

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

    def run_responder(request)
      self.class.responder_for(request) do |responder, *args|
        responder ||= self.class.user_defined_responders(:fallback).first

        next if responder.nil?
        case
        when responder[:respond]
          request.reply.text responder[:respond]
        when responder[:proc]
          define_singleton_method :process, responder[:proc]
          number_of_block_parameter = responder[:proc].arity
          send(:process, *args.unshift(request).take(number_of_block_parameter))
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
        msg = gen_msg(encrypt, params[:timestamp], params[:nonce])
      end

      msg
    end

    def gen_msg(encrypt, timestamp, nonce)
      msg_sign = Signature.hexdigest(@wechat_config.token, timestamp, nonce, encrypt)

      {
        Encrypt: encrypt,
        MsgSignature: msg_sign,
        TimeStamp: timestamp,
        Nonce: nonce
      }.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    end

    def request_encrypt_content
      request_content&.dig('xml', 'Encrypt')
    end

    def request_content
      params[:xml].nil? ? Hash.from_xml(request.raw_post) : { 'xml' => params[:xml] }
    end
    
  end
end
