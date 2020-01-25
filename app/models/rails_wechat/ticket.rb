module RailsWechat::Ticket
  extend ActiveSupport::Concern
  included do
    attribute :serial_start, :integer
    attribute :start_at, :time, default: -> { '0:00'.to_time }
    attribute :finish_at, :time, default: -> { '23:59'.to_time }
    attribute :valid_response, :string
    attribute :invalid_response, :string

    belongs_to :organ, optional: true
    has_one :wechat_response, as: :effective
    has_many :ticket_items, dependent: :nullify
  end

  def effective?(time = Time.now)
    time > start_at.change(Date.today.parts) && time < finish_at.change(Date.today.parts)
  end

  def invoke_effect(wechat_request)
    if effective?
      ti = self.ticket_items.create(wechat_request_id: wechat_request.id, serial_number: serial_number)
      ti.respond_text
    else
      invalid_response.presence
    end
  end

  def serial_number(now = Time.current)
    begin_at = now.beginning_of_month - 1.day
    end_at = now.next_month.beginning_of_month - 1.day
    serial_init = serial_start.presence || (now.strftime('%Y%m') + '0001').to_i
    if now < end_at
      last_item = self.ticket_items.default_where('created_at-gte': begin_at).order(serial_number: :desc).first
      if last_item
        last_item.serial_number + 1
      else
        serial_init
      end
    else
      serial_init = (now.next_month.strftime('%Y%m') + '0001').to_i
      last_item = self.ticket_items.default_where('created_at-gte': end_at).order(serial_number: :desc).first
      if last_item
        last_item.serial_number + 1
      else
        serial_init
      end
    end
  end

  def wechat_app
    if WechatApp.column_names.include?('organ_id')
      WechatApp.find_by(organ_id: self.organ_id, primary: true)
    else
      WechatApp.find_by(primary: true)
    end
  end

end
