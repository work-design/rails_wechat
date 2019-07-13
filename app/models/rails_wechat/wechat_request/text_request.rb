module RailsWechat::WechatRequest::TextRequest
  
  def response
    res = "#{wechat_app.help}"
    return res unless body.match? Regexp.new(wechat_app.match_values)
    res = wechat_app.text_responses.map do |wr|
      if body.match?(Regexp.new(wr.match_value))
        wr.invoke_effect(self)
      end
    end.compact
    
    "#{wechat_app.help_feedback}#{res.join(', ')}"
  end
  
end
