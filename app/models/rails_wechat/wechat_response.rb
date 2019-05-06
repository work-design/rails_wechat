module RailsWechat::WechatResponse
  extend ActiveSupport::Concern
  included do
    attribute :type, :string, default: 'TextResponse'
    attribute :match_value, :string
    
    belongs_to :wechat_config
    belongs_to :effective, polymorphic: true, optional: true
    
    validates :match_value, presence: true
    
    before_validation do
      self.match_value ||= "#{effective_type}_#{effective_id}"
    end
  end

  def invoke_effect(wechat_user)
    effective.invoke_effect(wechat_user) if effective
  end
  
end
