class SuccessReply < WechatReply
  include RailsWechat::WechatReply::SuccessReply
end unless defined? SuccessReply
