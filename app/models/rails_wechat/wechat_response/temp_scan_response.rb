module RailsWechat::WechatResponse::TempScanResponse
  extend ActiveSupport::Concern
  included do
    attribute :expire_seconds, :integer, default: 2592000
  end
  
  def sync
    Wechat.api(wechat_config.account).qrcode_create_scene self.match_value
  end
  
end
