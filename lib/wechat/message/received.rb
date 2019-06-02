module Wechat::Message
  class Received < Base
    # see: https://mp.weixin.qq.com/wiki?id=mp1421140453
    MSG_TYPE = [
      'text', 'image', 'voice', 'video', 'shortvideo', 'location', 'link', 'event' # 消息类型
    ].freeze
    # see: https://mp.weixin.qq.com/wiki?id=mp1421140454
    # see: https://work.weixin.qq.com/api/doc#90000/90135/90240
    EVENT = [
      'subscribe', 'unsubscribe', 'LOCATION', # 公众号与企业微信通用
      'CLICK', 'VIEW', 'SCAN',  # 公众号使用
      'click', 'view',  # 企业微信使用
      'scancode_push', 'scancode_waitmsg', 'pic_sysphoto', 'pic_photo_or_album', 'pic_weixin', 'location_select', 'enter_agent', 'batch_job_result'  # 企业微信使用
    ].freeze
    
    def initialize(app, message_body)
      @app = app
      @message_body = message_body
      post_xml
    end

    def post_xml
      data = Hash.from_xml(@message_body).fetch('xml', {})
      encrypt_data = data.fetch('Encrypt')
      
      if encrypt_data.present?
        r = Base64.decode64(encrypt_data)
        r = Wechat::Cipher.decrypt(r, @app.encoding_aes_key)
        content, @we_app_id = Wechat::Cipher.unpack(r)

        data = Hash.from_xml(content).fetch('xml', {})
      end
      @message_hash = data.with_indifferent_access
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
        ToUserName: @message_hash['FromUserName'],
        FromUserName: @message_hash['ToUserName'],
        CreateTime: Time.now.to_i
      )
    end
    
  end
end
