module RailsWechat::WechatRequest::TextRequest
  
  def response
    return unless body.match? Regexp.new(wechat_config.match_values)
    res = wechat_config.text_responses.map do |wr|
      if body.match?(Regexp.new(wr.match_value))
        wr.response(self.id)
      end
    end.compact
  
    "#{received.app.help_feedback}#{res.join(', ')}"
  end
  
end
