class WechatRequestLink < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestLink
end unless defined? WechatRequestLink
