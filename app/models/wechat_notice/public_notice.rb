class PublicNotice < WechatNotice
  include RailsWechat::WechatNotice::PublicNotice
end unless defined? PublicNotice
