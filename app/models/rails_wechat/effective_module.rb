module RailsWechat::EffectiveModule
  
  def invoke_effect(wechat_user)
    p 'please implement in class'
  end

  def qrcode_later
    WechatQrcodeJob.perform_later(self)
  end
  
  def wechat_config
    if WechatConfig.column_names.include?('organ_id')
      WechatConfig.find_by(organ_id: nil, primary: true)
    else
      WechatConfig.find_by(primary: true)
    end
  end

  def qrcode
    if wechat_response
      wechat_response
    else
      create_wechat_response(type: 'TempScanResponse', wechat_config_id: wechat_config.id) if wechat_config
    end
  end

  def qrcode_url
    wechat_response&.qrcode_file_url
  end
  
end
