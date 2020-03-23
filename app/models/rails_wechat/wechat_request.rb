module RailsWechat::WechatRequest
  extend ActiveSupport::Concern
  included do
    attribute :type, :string
    attribute :body, :string
    attribute :raw_body, :json
    attribute :msg_type, :string
    attribute :event, :string
    attribute :event_key, :string

    belongs_to :wechat_user
    belongs_to :wechat_app
    has_many :extractions, -> { order(id: :asc) }, as: :extractable, inverse_of: :wechat_request, dependent: :delete_all  # 解析 request body 内容，主要针对文字
    has_many :wechat_responses, ->(o){ where(request_type: o.type) }, primary_key: :wechat_app_id, foreign_key: :wechat_app_id
  end

  def do_extract
  end

  def response
    filtered = @rules.find do |rule|
      next unless rule[:msg_type].to_s == @message_hash['MsgType']

      if rule[:msg_type] == :event
        next unless rule[:event].underscore == @message_hash['Event'].underscore
      end

      if rule[:with]
        @with.match? rule[:with]
      else
        true
      end
    end

    if filtered
      filtered[:proc].call(self)
    else
      {}
    end
  end

  class_methods do

    def on(msg_type, event: nil, with: nil, &block)
      @configs ||= []
      config = { msg_type: msg_type }
      config[:proc] = block if block_given?

      if msg_type == :event
        if event
          config[:event] = event
        else
          raise 'Must appoint event type'
        end
      end

      if with.present?
        unless WITH_TYPE.include?(msg_type)
          warn "Only #{WITH_TYPE.join(', ')} can having :with parameters", uplevel: 1
        end

        case with
        when String, Regexp
          config[:with] = with
        else
          raise 'With is only support String or Regexp!'
        end
      end

      @configs << config
      config
    end

  end


end
