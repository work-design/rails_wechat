class EventResponse < WechatResponse
  include RailsWechat::WechatResponse::EventResponse
end unless defined? EventResponse
