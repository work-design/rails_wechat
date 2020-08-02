class ScanRequest < WechatRequest
  include RailsWechat::WechatRequest::ScanRequest
end unless defined? ScanRequest
