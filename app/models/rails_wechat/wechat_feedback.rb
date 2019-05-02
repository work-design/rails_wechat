module RailsWechat::WechatFeedback
  extend ActiveSupport::Concern
  included do
    attribute :feedback_on, :date, default: -> { Date.today }
    acts_as_list scope: [:feedback_on]
    
    belongs_to :wechat_user
  end
  
end
