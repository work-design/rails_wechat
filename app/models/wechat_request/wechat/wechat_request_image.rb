class WechatRequestImage < WechatRequest
  include RailsWechat::WechatRequest::WechatRequestImage
end unless defined? WechatRequestImage
