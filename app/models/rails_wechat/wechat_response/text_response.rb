module RailsWechat::WechatResponse::TextResponse

  def scan_regexp(body)
    if contain
      body.match? Regexp.new(match_value)
    else
      !body.match?(Regexp.new match_value)
    end
  end

end
