module RailsWechat::ResponseItem
  extend ActiveSupport::Concern
  included do
    attribute :respond_on, :date, default: -> { Date.today }
    attribute :respond_in, :string, default: -> { Date.today.strftime('%Y%m') }
    attribute :position, :integer, default: 1
    
    acts_as_list scope: [:wechat_response_id, :respond_in]
    
    belongs_to :wechat_response
    belongs_to :wechat_request
    belongs_to :wechat_user
    
    before_validation do
      self.wechat_user ||= wechat_request.wechat_user
    end
  end
  
  def respond_text
    "#{wechat_response.valid_response}#{number_str}"
  end
  
  def number_str
    self.respond_in.to_s + self.position.to_s.rjust(4, '0')
  end
  
end
