module RailsWechat::WechatResponse::PersistScanResponse
  extend ActiveSupport::Concern
  included do
  end

  def commit_to_wechat
    unless self.qrcode_ticket
      r = Wechat.api(wechat_app.id).qrcode_create_limit_scene self.match_value
      self.update(qrcode_ticket: r['ticket'], qrcode_url: r['url'])
    end
  end

end
