module Wechat::Message
  class ReceivedMessage
    MSG_TYPE = [
      'text', 'image', 'voice', 'video', 'shortvideo', 'location', 'link', 'event' # 消息类型
    ].freeze
    EVENT = [
      'subscribe', 'unsubscribe', 'LOCATION', # 公众号与企业微信通用
      'CLICK', 'VIEW', 'SCAN',  # 公众号使用
      'click', 'view',  # 企业微信使用
      'scancode_push', 'scancode_waitmsg', 'pic_sysphoto', 'pic_photo_or_album', 'pic_weixin', 'location_select', 'enter_agent', 'batch_job_result'  # 企业微信使用
    ].freeze
    
    
  end
end
