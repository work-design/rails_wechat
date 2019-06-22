module RailsWechat::Effective
  extend ActiveSupport::Concern
  included do
    has_one :wechat_response, as: :effective
  end
  
  def invoke_effect(wechat_user)
    p 'please implement in class'
  end

  def qrcode_later
    WechatQrcodeJob.perform_later(self)
  end
  
  def default_params
    { organ_id: nil }
  end

  def qrcode
    wechat_config = WechatConfig.where(default_params).primary
    unless wechat_response
      create_wechat_response(type: 'TempScanResponse', wechat_config_id: wechat_config.id) if wechat_config
    end
  end

  def qrcode_url
    wechat_response&.qrcode_file_url
  end
  
end
