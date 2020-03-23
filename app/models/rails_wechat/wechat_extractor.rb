module RailsWechat::WechatExtractor
  extend ActiveSupport::Concern

  included do
    attribute :name, :string
    attribute :prefix, :string
    attribute :suffix, :string
    attribute :more, :boolean, default: false
    attribute :serial, :boolean, default: false
    attribute :serial_start, :integer
    attribute :start_at, :time, default: -> { '0:00'.to_time }
    attribute :finish_at, :time, default: -> { '23:59'.to_time }
    attribute :valid_response, :string
    attribute :invalid_response, :string

    belongs_to :wechat_response
    has_many :wechat_extractions, dependent: :nullify
  end

  def scan_regexp
    if more
      /(?<=#{prefix}).*(?=#{suffix})/
    else
      /(?<=#{prefix}).*?(?=#{suffix})/
    end
  end

  def effective?(time = Time.current)
    time > start_at.change(Date.today.parts) && time < finish_at.change(Date.today.parts)
  end

  def serial_number(now = Time.current)
    begin_at = now.beginning_of_month - 1.day
    end_at = now.next_month.beginning_of_month - 1.day
    serial_init = serial_start.presence || (now.strftime('%Y%m') + '0001').to_i
    if now < end_at
      last_item = extractions.where.not(serial_number: nil).default_where('created_at-gte': begin_at).order(serial_number: :desc).first
      if last_item
        last_item.serial_number + 1
      else
        serial_init
      end
    else
      serial_init = (now.next_month.strftime('%Y%m') + '0001').to_i
      last_item = extractions.where.not(serial_number: nil).default_where('created_at-gte': end_at).order(serial_number: :desc).first
      if last_item
        last_item.serial_number + 1
      else
        serial_init
      end
    end
  end

end

