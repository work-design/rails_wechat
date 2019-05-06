class WechatFeedback < ApplicationRecord
  include RailsWechat::WechatFeedback
  include RailsWechat::Extractable
  after_save_commit :do_extract, if: -> { saved_change_to_body? }

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
  
end unless defined? WechatFeedback
