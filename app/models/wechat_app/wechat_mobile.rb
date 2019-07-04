class WechatMobile < WechatApp
  include RailsWechat::WechatApp::WechatMobile
end unless defined? WechatMobile
