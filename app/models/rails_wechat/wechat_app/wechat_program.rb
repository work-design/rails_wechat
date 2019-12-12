module RailsWechat::WechatApp::WechatProgram
  extend ActiveSupport::Concern
  
  included do
  
  end
  
  def api
    Wechat::Api::Program.new(self)
  end

end
