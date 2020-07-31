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
    attribute :appid, :string, index: true
    attribute :open_id, :string, index: true

    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    has_many :wechat_receiveds, dependent: :nullify
    has_many :wechat_extractions, -> { order(id: :asc) }, dependent: :delete_all  # 解析 request body 内容，主要针对文字
    has_many :wechat_responses, ->(o){ where(request_type: o.type) }, primary_key: :wechat_app_id, foreign_key: :wechat_app_id
  end

  def reply
    reply_from_rule
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

    filtered[:proc].call(self) if filtered
  end

  def kefu(text)
    custom = Wechat::Message::Custom.new(wechat_app)
    custom.to(wechat_user.uid)
    custom.update(
      msgtype: 'text',
      text:
        {
          content: text
        }
    )
    custom.do_send
  end

  # Typing
  # CancelTyping
  def typing(command = 'Typing')
    wechat_app.api.message_custom_typing(wechat_user.uid, command)
  end

  class_methods do

    def on(msg_type: nil, body: nil, event: nil, proc: nil, &block)
      config = {
        msg_type: msg_type,
        event: event,
        body: body,
        proc: proc
      }
      config[:proc] = block if block_given?

      rules << config
    end

  end


end
