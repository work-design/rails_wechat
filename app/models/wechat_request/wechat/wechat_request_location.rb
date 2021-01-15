class WechatRequestLocation < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestLocation
end unless defined? WechatRequestLocation
