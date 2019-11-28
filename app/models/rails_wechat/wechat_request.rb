module RailsWechat::WechatRequest
  extend ActiveSupport::Concern
  included do
    attribute :type, :string
    attribute :body, :text
    
    belongs_to :wechat_user
    belongs_to :wechat_app
    has_many :extractions, as: :extractable  # 解析 request body 内容，主要针对文字
    has_many :ticket_items, dependent: :delete_all
    
    after_save_commit :do_extract, if: -> { saved_change_to_body? }
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
  
  def response
    "你的反馈已收到"
  end
  
end
