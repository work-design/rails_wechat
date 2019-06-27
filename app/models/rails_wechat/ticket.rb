module RailsWechat::Ticket
  extend ActiveSupport::Concern
  included do
    attribute :serial_start, :integer
    
    has_many :ticket_items
  end
  
  def respond_text
    "#{wechat_response.valid_response}#{number_str}"
  end
  
  def number_str
    self.created_at.to_s + self.serial_number.to_s.rjust(4, '0')
  end
  
end
