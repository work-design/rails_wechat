class WechatPublic < WechatConfig
  include RailsWechat::WechatConfig::WechatPublic
end unless defined? WechatPublic
