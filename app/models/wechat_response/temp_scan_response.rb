class TempScanResponse < ScanResponse
  include RailsWechat::WechatResponse::TempScanResponse
end unless defined? TempScanResponse
