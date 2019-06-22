module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    
    attribute :feedback_on, :date, default: -> { Date.today }
    attribute :position, :integer, default: 1
    
    acts_as_list scope: [:wechat_config_id, :feedback_on]
    
    belongs_to :wechat_user
    belongs_to :wechat_config
    has_many :response_items, dependent: :destroy
  end
  
  def number_str
    self.feedback_on.strftime('%Y%m%d') + self.position.to_s.rjust(4, '0')
  end
  
end
