module RailsWechat::WechatRequest::TextRequest
  
  def response
    res = "请按标准模板填写"
    return res unless body.match? Regexp.new(wechat_config.match_values)
    res = wechat_config.text_responses.map do |wr|
      if body.match?(Regexp.new(wr.match_value))
        wr.invoke_effect(self)
      end
    end.compact
    
    "#{wechat_config.help_feedback}#{res.join(', ')}"
  end
  
end
