class VideoReply < WechatReply
  include RailsWechat::WechatReply::VideoReply
end unless defined? VideoReply
