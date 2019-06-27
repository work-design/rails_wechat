module RailsWechat::ResponseItem
  extend ActiveSupport::Concern
  included do
    attribute :serial_number, :integer
    
    acts_as_list column: 'serial_number', scope: [:wechat_response_id]
    
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
    self.created_at.to_s + self.serial_number.to_s.rjust(4, '0')
  end
  
end
