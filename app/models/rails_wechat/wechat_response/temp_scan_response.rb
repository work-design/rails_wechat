module RailsWechat::WechatResponse::TempScanResponse
  extend ActiveSupport::Concern
  included do
    attribute :expire_seconds, :integer, default: 2592000
  end
  
  def commit_to_wechat
    r = Wechat.api(wechat_app.id).qrcode_create_scene self.match_value, expire_seconds
    self.update(qrcode_ticket: r['ticket'], qrcode_url: r['url'], expire_at: Time.current + expire_seconds)
  end
  
  def refresh
    unless effective?
      sync
    end
    self
  end
  
end
