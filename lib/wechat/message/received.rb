module Wechat::Message
  class Received
    # see: https://mp.weixin.qq.com/wiki?id=mp1421140453
    MSG_TYPE = [
      'text', 'image', 'voice', 'video', 'shortvideo', 'location', 'link', 'event' # 消息类型
    ].freeze
    EVENT = [
      'subscribe', 'unsubscribe', 'LOCATION', # 公众号与企业微信通用
      'CLICK', 'VIEW', 'SCAN',  # 公众号使用
      'click', 'view',  # 企业微信使用
      'scancode_push', 'scancode_waitmsg', 'pic_sysphoto', 'pic_photo_or_album', 'pic_weixin', 'location_select', 'enter_agent', 'batch_job_result'  # 企业微信使用
    ].freeze


    def initialize(app, params)
      @app = app
      post_xml
      super
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

    def as(type)
      case type
      when :text
        @message_hash[:Content]
      when :image, :voice, :video
        Wechat.api.media(@message_hash[:MediaId])
      when :location
        @message_hash.slice(:Location_X, :Location_Y, :Scale, :Label).each_with_object({}) do |value, results|
          results[value[0].to_s.underscore.to_sym] = value[1]
        end
      else
        raise "Don't know how to parse message as #{type}"
      end
    end

    def reply
      Replied.new(
        ToUserName: @message_hash[:FromUserName],
        FromUserName: @message_hash[:ToUserName],
        CreateTime: Time.now.to_i
      )
    end
    
    
    def response
    
    end
    
  end
end
