class TextRequest < WechatRequest
  include RailsWechat::WechatRequest::TextRequest
end unless defined? TextRequest
