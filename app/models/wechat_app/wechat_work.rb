class WechatWork < WechatApp
  include RailsWechat::WechatApp::WechatWork
end unless defined? WechatWork
