class ImageService < WechatService
  include RailsWechat::WechatService::ImageService
end unless defined? ImageService
