class VideoService < WechatService
  include RailsWechat::WechatService::VideoService
end unless defined? VideoService
