module RailsWechat::WechatResponse::TempScanResponse
  extend ActiveSupport::Concern
  included do
    attribute :expire_seconds, :integer, default: 2592000
  end
  
  def commit_to_wechat
    unless self.qrcode_ticket
      r = Wechat.api(wechat_config.account).qrcode_create_scene self.match_value
      self.update(qrcode_ticket: r['ticket'], qrcode_url: r['url'])
    end
  end
  
end
