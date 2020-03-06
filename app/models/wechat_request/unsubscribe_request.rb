class UnsubscribeRequest < WechatRequest
  include RailsWechat::WechatRequest::UnsubscribeRequest
end unless defined? UnsubscribeRequest
