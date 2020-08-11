class TextService < WechatService
  include RailsWechat::WechatService::TextService
end unless defined? TextService
