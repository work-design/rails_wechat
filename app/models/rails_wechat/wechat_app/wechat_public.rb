module RailsWechat::WechatApp::WechatPublic
  extend ActiveSupport::Concern
  included do
  
  end
  
  def api
    Wechat::Api::Public.new(self)
  end

end
