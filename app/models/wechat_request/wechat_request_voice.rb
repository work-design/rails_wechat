class WechatRequestVoice < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestVoice
end unless defined? WechatRequestVoice
