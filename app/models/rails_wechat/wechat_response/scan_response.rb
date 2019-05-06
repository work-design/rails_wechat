module RailsWechat::WechatResponse::ScanResponse
  extend ActiveSupport::Concern
  included do
    has_one_attached :qrcode_file
    after_save_commit :sync, if: -> { saved_change_to_match_value? }
  end
  
  def sync
    commit_to_wechat
    persist_to_file
  end
  
  def commit_to_wechat
    p 'should implement in subclass'
  end
  
  def persist_to_file
    file = QrcodeHelper.code_file self.qrcode_url
    self.qrcode_file.attach io: file, filename: self.qrcode_url
  end
 
end
