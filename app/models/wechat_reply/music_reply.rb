class MusicReply < WechatReply
  include RailsWechat::WechatReply::MusicReply
end unless defined? MusicReply
