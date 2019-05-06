module RailsWechat::Extractable
  extend ActiveSupport::Concern
  included do
    has_many :extractions, as: :extractable
  end

  def test_extract
    wechat_config.extractors.map do |extractor|
      matched = body.scan(extractor.scan_regexp)
      if matched.blank?
        next
      else
        matched.join(', ')
      end
    end
  end

  def do_extract
    wechat_config.extractors.map do |extractor|
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
