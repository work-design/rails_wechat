module RailsWechat::WechatResponse
  extend ActiveSupport::Concern
  included do
    attribute :type, :string, default: 'TextResponse'
    attribute :match_value, :string
    attribute :start_at, :time, default: -> { '0:00'.to_time }
    attribute :finish_at, :time, default: -> { '23:59'.to_time }
    
    belongs_to :wechat_config
    belongs_to :effective, polymorphic: true, optional: true
    has_many :response_items, dependent: :nullify
    
    validates :match_value, presence: true
    
    before_validation do
      self.match_value ||= "#{effective_type}_#{effective_id}"
    end
  end
  
  def effective?(time = Time.now)
    time > start_at.change(Date.today.parts) && time < finish_at.change(Date.today.parts)
  end

  def invoke_effect(wechat_user)
    effective.invoke_effect(wechat_user) if effective
  end
  
end
