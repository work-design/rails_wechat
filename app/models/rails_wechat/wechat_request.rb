module RailsWechat::WechatRequest
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: 'Rails.application.routes'

    attribute :type, :string
    attribute :body, :string
    attribute :raw_body, :json
    attribute :msg_type, :string
    attribute :event, :string
    attribute :event_key, :string
    attribute :appid, :string, index: true
    attribute :open_id, :string, index: true
    attribute :reply_body, :json
    attribute :reply_encrypt, :json

    belongs_to :wechat_reply, optional: true
    belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
    belongs_to :wechat_app, foreign_key: :appid, primary_key: :appid, optional: true
    has_one :wechat_received
    has_many :wechat_receiveds, dependent: :nullify
    has_many :wechat_extractions, -> { order(id: :asc) }, dependent: :delete_all  # 解析 request body 内容，主要针对文字
    has_many :wechat_response_requests, ->(o){ where(request_type: o.type) }, primary_key: :appid, foreign_key: :appid
    has_many :wechat_responses, through: :wechat_response_requests

    before_save :get_reply_body, if: -> { (wechat_reply_id_changed? || new_record? || wechat_reply&.new_record?) && wechat_reply }
  end

  def reply
    reply_from_rule
  end

  def rule_tag
    {
      msg_type: msg_type,
      event: event,
      body: body
    }.compact
  end

  def reply_from_rule
    filtered = RailsWechat.config.rules.find do |_, rule|
      rule.slice(:msg_type, :event, :body) == self.rule_tag
    end

    filtered[1][:proc].call(self) if filtered.present?
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

  def get_reply_body
    if wechat_reply
      self.reply_body = wechat_reply.to_wechat
      self.reply_body.merge!(ToUserName: open_id)
    else
      self.reply_body = {}
    end
    if encrypt_mode
      do_encrypt
    end
  end

  def encrypt_mode
    wechat_app.encrypt_mode || wechat_received&.wechat_platform.present?
  end

  def encoding_aes_key
    wechat_app.encoding_aes_key.presence || wechat_received&.wechat_platform&.encoding_aes_key
  end

  def encrypt_appid
    wechat_received&.wechat_platform&.appid || appid
  end

  def token
    wechat_app.token
  end

  def do_encrypt
    return unless encrypt_mode

    nonce = SecureRandom.hex(10)
    #content = reply_body.merge(FuncFlag: 0).to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    encrypt = Base64.strict_encode64(Wechat::Cipher.encrypt(Wechat::Cipher.pack(to_xml, encrypt_appid), encoding_aes_key))
    timestamp = reply_body['CreateTime']
    msg_sign = Wechat::Signature.hexdigest(token, timestamp, nonce, encrypt)

    self.reply_encrypt = {
      Encrypt: encrypt,
      MsgSignature: msg_sign,
      TimeStamp: timestamp,
      Nonce: nonce
    }
  end

  def to_wechat
    if reply_encrypt.present?
      reply_encrypt.to_xml(
        root: 'xml',
        children: 'item',
        skip_instruct: true,
        skip_types: true)
    else
      to_xml
    end
  end

  def to_xml
    if reply_body.blank?
      'success'
    else
      reply_body.to_xml(
        root: 'xml',
        children: 'item',
        skip_instruct: true,
        skip_types: true
      )
    end
  end

end
