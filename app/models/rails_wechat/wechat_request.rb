module RailsWechat::WechatRequest
  extend ActiveSupport::Concern
  included do
    mattr_accessor :rules, default: []  # 用于配置 reply 的逻辑

    attribute :type, :string
    attribute :body, :string
    attribute :raw_body, :json
    attribute :msg_type, :string
    attribute :event, :string
    attribute :event_key, :string

    belongs_to :wechat_user
    belongs_to :wechat_app
    has_many :wechat_extractions, -> { order(id: :asc) }, dependent: :delete_all  # 解析 request body 内容，主要针对文字
    has_many :wechat_responses, ->(o){ where(request_type: o.type) }, primary_key: :wechat_app_id, foreign_key: :wechat_app_id
  end

  def do_extract
  end

  def rule_tag
    {
      msg_type: msg_type,
      event: event,
      body: body
    }
  end

  def reply_from_rule
    filtered = rules.find do |rule|
      rule.slice(:msg_type, :event, :body) == self.rule_tag
    end

    if filtered
      filtered[:proc].call(self)
    else
      {}
    end
  end

  class_methods do

    def on(msg_type: nil, body: nil, event: nil, &block)
      config = {
        msg_type: msg_type,
        event: event,
        body: body,
      }
      config[:proc] = block if block_given?

      rules << config
    end

  end


end
