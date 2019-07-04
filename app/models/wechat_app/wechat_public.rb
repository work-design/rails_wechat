class WechatPublic < WechatApp
  include RailsWechat::WechatApp::WechatPublic
end unless defined? WechatPublic
