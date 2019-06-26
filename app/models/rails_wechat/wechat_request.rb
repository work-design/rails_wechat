module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    
    attribute :feedback_on, :date, default: -> { Date.today }
    attribute :position, :integer, default: 1
    
    acts_as_list scope: [:wechat_config_id, :feedback_on]
    
    belongs_to :wechat_user
    belongs_to :wechat_config
    has_many :response_items, dependent: :destroy
    has_many :extractions, as: :extractable

    after_save_commit :do_extract, if: -> { saved_change_to_body? }
  end
  
  def number_str
    self.feedback_on.strftime('%Y%m%d') + self.position.to_s.rjust(4, '0')
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
