module RailsWechat::WechatResponse::TextResponse

  def scan_regexp(body)
    if contain
      body.match? Regexp.new(match_value)
    else
      !body.match?(Regexp.new match_value)
    end
  end

  def invoke_effect(request_from)
    do_extract(request_from)
    super
  end

  def do_extract(wechat_request)
    wechat_app.extractors.map do |extractor|
      matched = wechat_request.body.scan(extractor.scan_regexp)
      next if matched.blank?

      ex = wechat_request.extractions.find_or_initialize_by(extractor_id: extractor.id)
      ex.name = extractor.name
      ex.matched = matched.join(', ')

      if extractor.effective?
        ex.serial_number = extractor.serial_number
        r = ex.respond_text
      else
        r = extractor.invalid_response.presence
      end
      ex.save

      r
    end.compact
  end

end
