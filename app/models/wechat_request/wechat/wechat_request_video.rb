class WechatRequestVideo < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestVideo
end unless defined? WechatRequestVideo
