module Wechat
  module Model::Extractor
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

      belongs_to :response
      has_many :extractions, dependent: :nullify
    end

    def scan_regexp
      if more
        /(?<=#{prefix}).*(?=#{suffix})/
      else
        /(?<=#{prefix}).*?(?=#{suffix})/
      end
    end

    def invoke_effect(request)
      matched = request.body.scan(scan_regexp)
      if matched.blank?
        return
      else
        logger.debug "  \e[35m=====> Matched: #{matched.inspect}, Extractor: #{name}(#{id})\e[0m"
      end

      # 这里不用 find_or_initialize_by，因为可以建立 ex.extractor, 减少 belongs_to validation present 的数据库查询
      ex = request.extractions.find_by(extractor_id: id) || request.extractions.build(extractor: self)
      ex.name = name
      ex.matched = matched.join(', ')
      if serial && effective?(request.created_at)
        ex.serial_number ||= serial_number
        r = ex.respond_text
      else
        r = invalid_response.presence
      end
      r
    end

    def effective?(time = Time.current)
      time > start_at.change(time.to_date.parts) && time < finish_at.change(time.to_date.parts)
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
end
