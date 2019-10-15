module RailsWechat::WechatApp::WechatProgram
  extend ActiveSupport::Concern
  
  included do
  
  end
  
  
  def get_phone_number()
    xx = Wechat::Cipher.program_decrypt()
    
  end

end
