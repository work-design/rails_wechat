class PersistScanResponse < ScanResponse
  include RailsWechat::WechatResponse::PersistScanResponse
end unless defined? PersistScanResponse
