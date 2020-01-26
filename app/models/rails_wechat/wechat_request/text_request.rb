module RailsWechat::WechatRequest::TextRequest
  extend ActiveSupport::Concern
  included do
    after_save_commit :do_extract, if: -> { saved_change_to_body? }
  end

  def response
    res = wechat_app.text_responses.map do |wr|
      if wr.scan_regexp(body)
        wr.invoke_effect(self)
      end
    end.compact

    if res.present?
      res.join("\n")
    else
      wechat_app.help
    end
  end

  def do_extract
    res = wechat_app.extractors.map do |extractor|
      matched = body.scan(extractor.scan_regexp)
      next if matched.blank?

      ex = self.extractions.find_or_initialize_by(extractor_id: extractor.id)
      ex.name = extractor.name
      ex.matched = matched.join(', ')
      ex.save
      ex.serial_number
    end.compact

    if res.present?
      res.join("\n")
    else
      wechat_app.help
    end
  end

end
