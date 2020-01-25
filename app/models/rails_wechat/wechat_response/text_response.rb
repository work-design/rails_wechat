module RailsWechat::WechatResponse::TextResponse

  def scan_regexp
    if contained
      /#{match_value}/
    else
      /^((?!#{match_value}).)*$/
    end
  end

end
