class ViewRequest < WechatRequest
  include RailsWechat::WechatRequest::ViewRequest
end unless defined? ViewRequest
