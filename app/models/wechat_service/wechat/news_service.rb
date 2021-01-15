class NewsService < WechatService
  include RailsWechat::WechatService::NewsService
end unless defined? NewsService
