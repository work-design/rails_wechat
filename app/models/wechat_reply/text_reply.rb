class TextReply < WechatReply
  include RailsWechat::WechatReply::TextReply
end unless defined? TextReply
