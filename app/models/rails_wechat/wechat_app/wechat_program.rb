module RailsWechat::WechatApp::WechatProgram
  extend ActiveSupport::Concern
  
  included do
  
  end
  
  
  def get_phone_number(encrypted_data, iv, session_key)
    r = Wechat::Cipher.program_decrypt(encrypted_data, iv, session_key)
    r['phoneNumber']
  end

end
