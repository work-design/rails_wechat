class SubscribeRequest < WechatRequest
  include RailsWechat::WechatRequest::SubscribeRequest
end unless defined? SubscribeRequest
