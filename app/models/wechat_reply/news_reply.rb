class NewsReply < WechatReply
  include RailsWechat::WechatReply::NewsReply
end unless defined? NewsReply
