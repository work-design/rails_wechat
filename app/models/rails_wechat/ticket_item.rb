module RailsWechat::TicketItem
  extend ActiveSupport::Concern
  included do
    attribute :serial_number, :integer
    
    belongs_to :ticket
    belongs_to :wechat_request
    belongs_to :wechat_user
    
    before_validation do
      self.wechat_user ||= wechat_request.wechat_user
    end
  end
  
  def respond_text
    "#{ticket.valid_response}#{serial_number}"
  end
  
end
