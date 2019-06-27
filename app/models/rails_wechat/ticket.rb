module RailsWechat::Ticket
  extend ActiveSupport::Concern
  included do
    attribute :serial_start, :integer
    attribute :start_at, :time, default: -> { '0:00'.to_time }
    attribute :finish_at, :time, default: -> { '23:59'.to_time }
    
    has_many :ticket_items, dependent: :nullify
  end
  
  def respond_text
    "#{wechat_response.valid_response}#{number_str}"
  end
  
  def number_str
    self.created_at.to_s + self.serial_number.to_s.rjust(4, '0')
  end

  def effective?(time = Time.now)
    time > start_at.change(Date.today.parts) && time < finish_at.change(Date.today.parts)
  end

  def invoke_effect(wechat_request)
    if effective?
      ri = self.ticket_items.create(wechat_request_id: wechat_request.id)
      ri.respond_text
    else
      invalid_response.presence
    end
  end
  
end
