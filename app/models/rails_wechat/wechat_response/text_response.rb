module RailsWechat::WechatResponse::TextResponse
  
  def response(wechat_request_id)
    if effective?
      ri = self.response_items.create(wechat_request_id: wechat_request_id)
      ri.respond_text
    else
      invalid_response.presence
    end
  end

end
