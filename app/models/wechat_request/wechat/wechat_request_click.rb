class WechatRequestClick < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestClick
end unless defined? WechatRequestClick
