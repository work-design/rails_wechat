module RailsWechat::WechatRequest::TextRequest
  
  
  def response
    if effective?
      ri = self.response_items.create(wechat_feedback_id: wf.id)
      ri.respond_text
    else
      invalid_response.presence
    end
  end
  
  def analyze
    return unless body.match? Regexp.new(wechat_config.match_values)
    res = wechat_config.text_responses.map do |wr|
      if body.match?(Regexp.new(wr.match_value))
        wr.response
      end
    end.compact
  
    "#{received.app.help_feedback}#{res.join(', ')}"
  end
  
end
