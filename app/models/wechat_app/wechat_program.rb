class WechatProgram < WechatApp
  include RailsWechat::WechatApp::WechatProgram
end unless defined? WechatProgram
