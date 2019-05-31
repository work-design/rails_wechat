class WechatWork < WechatConfig
  include RailsWechat::WechatConfig::WechatWork
end unless defined? WechatWork
