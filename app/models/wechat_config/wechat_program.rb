class WechatProgram < WechatConfig
  include RailsWechat::WechatConfig::WechatProgram
end unless defined? WechatProgram
