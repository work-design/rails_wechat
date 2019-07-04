module RailsWechat::WechatResponse
  extend ActiveSupport::Concern
  included do
    attribute :type, :string, default: 'TextResponse'
    attribute :match_value, :string
    attribute :expire_at, :datetime
    
    belongs_to :wechat_app
    belongs_to :effective, polymorphic: true, optional: true
    
    validates :match_value, presence: true
    
    before_validation do
      self.match_value ||= "#{effective_type}_#{effective_id}"
      self.expire_at = Time.current + expire_seconds if expire_seconds
    end
  end

  def effective?(time = Time.now)
    time < expire_at
  end

  def invoke_effect(request_from)
    effective.invoke_effect(request_from) if effective
  end
  
end
