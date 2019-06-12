module RailsWechat::WechatResponse::ScanResponse
  extend ActiveSupport::Concern
  included do
    delegate :url_helpers, to: 'Rails.application.routes'
  
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
  
  def qrcode_file_url
    url_helpers.rails_blob_url(qrcode_file) if qrcode_file.attachment.present?
  end
 
end
