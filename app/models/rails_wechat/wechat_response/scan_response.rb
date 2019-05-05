module RailsWechat::WechatResponse::ScanResponse
  extend ActiveSupport::Concern
  included do
    has_one_attached :qrcode_file
    after_save_commit :sync, if: -> { saved_change_to_match_value? }
  end
  
  def sync
    unless self.qrcode_ticket
      r = Wechat.api(wechat_config.account).qrcode_create_limit_scene self.match_value
      self.update(qrcode_ticket: r['ticket'], qrcode_url: r['url'])
    end
    
    file = QrcodeHelper.code_file self.qrcode_url
    self.qrcode_file.attach io: file, filename: self.qrcode_url
  end
  
 
end
