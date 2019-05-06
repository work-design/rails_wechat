module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    attribute :feedback_on, :date, default: -> { Date.today }
    attribute :month, :string, default: -> { Date.today.strftime('%Y%m') }
    acts_as_list scope: [:wechat_config_id, :month, :kind]
    
    belongs_to :wechat_user
    belongs_to :wechat_config
    has_many :extractions, as: :extractable
  end
  
  def number_str
    self.month.to_s + self.position.to_s.rjust(4, '0')
  end
  
  def do_extract
    wechat_config.extractors.map do |extractor|
      r = body.scan(extractor.scan_regexp)
      next if r.blank?
      matched = r.map do |c|
        if extractor.prefix?
          c.delete_prefix(extractor.match_value)
        elsif extractor.suffix?
          c.delete_sufffix(extractor.match_value)
        end
      end
      ex = self.extractions.find_or_initialize_by(extractor_id: extractor.id)
      ex.name = extractor.name
      ex.matched = matched.join(', ')
      ex.save
      ex
    end
  end
  
end
