class WechatApp < WechatConfig
  include RailsWechat::WechatConfig::WechatApp
end unless defined? WechatApp
