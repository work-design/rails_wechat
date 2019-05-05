class ScanResponse < WechatResponse
  include RailsWechat::WechatResponse::ScanResponse
end unless defined? ScanResponse
