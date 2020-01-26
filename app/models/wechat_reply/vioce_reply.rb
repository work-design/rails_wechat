class VoiceReply < WechatReply
  include RailsWechat::WechatReply::VoiceReply
end unless defined? VoiceReply
