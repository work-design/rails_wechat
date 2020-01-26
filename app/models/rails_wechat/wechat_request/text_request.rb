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

    "#{wechat_app.help_feedback}#{res.join(', ')}"
  end

  def do_extract
    wechat_app.extractors.map do |extractor|
      matched = body.scan(extractor.scan_regexp)
      next if matched.blank?

      ex = self.extractions.find_or_initialize_by(extractor_id: extractor.id)
      ex.name = extractor.name
      ex.matched = matched.join(', ')
      ex.save
      ex
    end
  end

end
