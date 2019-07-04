module RailsWechat::Extractable
  extend ActiveSupport::Concern
  included do
    has_many :extractions, as: :extractable
  end

  def test_extract
    wechat_app.extractors.map do |extractor|
      matched = body.scan(extractor.scan_regexp)
      if matched.blank?
        next
      else
        matched.join(', ')
      end
    end
  end
  
end
