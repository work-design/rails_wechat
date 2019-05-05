class TextResponse < WechatResponse
  include RailsWechat::WechatResponse::TextResponse
end unless defined? TextResponse
