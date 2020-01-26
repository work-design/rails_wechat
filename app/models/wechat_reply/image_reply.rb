class ImageReply < WechatReply
  include RailsWechat::WechatReply::ImageReply
end unless defined? ImageReply
