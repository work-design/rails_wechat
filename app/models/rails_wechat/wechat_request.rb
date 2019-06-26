module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    
    
    belongs_to :wechat_user
    belongs_to :wechat_config
    has_many :response_items, dependent: :destroy  # 自动response的具体信息
    has_many :extractions, as: :extractable  # 解析 request body 内容，主要针对文字

    after_save_commit :do_extract, if: -> { saved_change_to_body? }
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
  
  def response
    ''
  end
  
end
