module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    attribute :feedback_on, :date, default: -> { Date.today }
    attribute :month, :string, default: -> { Date.today.strftime('%Y%m') }
    acts_as_list scope: [:wechat_config_id, :month, :kind]
    
    belongs_to :wechat_user
    belongs_to :wechat_config
  end
  
  def number_str
    self.month.to_s + self.position.to_s.rjust(4, '0')
  end
  
end
