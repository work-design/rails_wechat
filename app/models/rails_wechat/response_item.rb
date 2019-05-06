module RailsWechat::ResponseItem
  extend ActiveSupport::Concern
  included do
    attribute :respond_at, :datetime, default: -> { Date.today }
    attribute :respond_on, :date, default: -> { Date.today }
    attribute :respond_in, :string, default: -> { Date.today.strftime('%Y%m') }
    
    acts_as_list scope: [:wechat_config_id, :wechat_respond_id, :respond_in]
    
    belongs_to :wechat_response
    belongs_to :wechat_feedback
    belongs_to :wechat_user
    
    before_validation do
      self.wechat_user ||= wechat_feedback.wechat_user
    end
  end
  
  def respond_text
    "#{wechat_response.response}：#{number_str}"
  end
  
  def number_str
    self.respond_in.to_s + self.position.to_s.rjust(4, '0')
  end
  
end
