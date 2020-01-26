module RailsWechat::WechatRequest::TextRequest
  extend ActiveSupport::Concern

  def response
    res = wechat_app.text_responses.map do |wr|
      if wr.scan_regexp(body)
        wr.invoke_effect(self)
      end
    end.compact
    res += do_extract

    if res.present?
      res.join("\n")
    else
      wechat_app.help
    end
  end

  def do_extract
    wechat_app.extractors.map do |extractor|
      matched = body.scan(extractor.scan_regexp)
      next if matched.blank?

      ex = extractions.find_or_initialize_by(extractor_id: extractor.id)
      ex.name = extractor.name
      ex.matched = matched.join(', ')
      if extractor.serial && extractor.effective?
        ex.serial_number = extractor.serial_number if ex.new_record?
        r = ex.respond_text
      else
        r = extractor.invalid_response.presence
      end
      ex.save

      r
    end.compact
  end

end
