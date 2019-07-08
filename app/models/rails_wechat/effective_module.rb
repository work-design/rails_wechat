module RailsWechat::EffectiveModule
  
  def invoke_effect(wechat_user)
    p 'please implement in class'
  end

  def qrcode_later
    WechatQrcodeJob.perform_later(self)
  end
  
  def wechat_app
    if WechatApp.column_names.include?('organ_id')
      WechatApp.find_by(organ_id: nil, primary: true)
    else
      WechatApp.find_by(primary: true)
    end
  end

  def qrcode
    if wechat_app
      wa = wechat_app
    else
      wa = backup_wechat_app
    end
    if wechat_response
      wechat_response
    else
      create_wechat_response(type: 'TempScanResponse', wechat_app_id: wa.id) if wa
    end
  end
  
  def backup_wechat_app
    app_id = Rails.application.credentials.dig(:wechat, Rails.env.to_sym, :appid)
    WechatApp.find_by(appid: app_id)
  end

  def qrcode_url
    wechat_response&.qrcode_file_url
  end
  
end
