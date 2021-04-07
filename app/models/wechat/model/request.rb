module Wechat
  module Model::Request
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

      belongs_to :receive
      belongs_to :reply, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :user_tag, optional: true

      has_one :platform, through: :receive
      has_one :tag, ->(o){ where(name: o.body) }, primary_key: :appid, foreign_key: :appid
      has_many :services, dependent: :nullify
      has_many :extractions, -> { order(id: :asc) }, dependent: :delete_all  # 解析 request body 内容，主要针对文字
      has_many :responses, ->(o){ default_where('request_types-any': o.type) }, primary_key: :appid, foreign_key: :appid

      before_save :get_reply_body, if: -> { (reply_id_changed? || new_record? || reply&.new_record?) && reply }
    end

    def get_reply
      self.reply = reply_from_rule
    end

    def rule_tag
      {
        msg_type: msg_type,
        event: event&.downcase,
        event_key: event_key
      }.compact
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        if rule.slice(:msg_type, :event, :event_key) <= self.rule_tag && rule[:body]
          rule[:body].match? self.body
        end
      end

      if filtered.present?
        logger.debug "  -----> Filter Key: #{filtered[1]}"
        filtered[1][:proc].call(self)
      end
    end

    # Typing
    # CancelTyping
    def typing(command = 'Typing')
      app.api.message_custom_typing(wechat_user.uid, command)
    end

    def bind_url
      Rails.application.routes.url_for(controller: 'auth/sign', action: 'sign', uid: wechat_user.uid, host: app.host)
    end

    def sync_to_tag
      tag || create_tag
      if wechat_user
        ut = wechat_user.user_tags.find_or_initialize_by(tag_id: tag.id)
        ut.source = self if ut.new_record?

        self.user_tag = ut

        self.class.transation do
          ut.save!
          self.save!
        end
      end
    end

    def get_reply_body
      if reply.is_a?(SuccessReply)
        self.reply_body = {}
      elsif reply
        self.reply_body = reply.to_wechat
        self.reply_body.merge!(ToUserName: open_id)
        self.reply_body.merge!(FromUserName: app.user_name) if app
      else
        self.reply_body = {}
      end
      do_encrypt
    end

    def do_encrypt
      if platform
        token = platform.token
        encoding_aes_key = platform.encoding_aes_key
        encrypt_appid = platform.appid
      elsif app.encrypt_mode
        token = app.token
        encoding_aes_key = app.encoding_aes_key
        encrypt_appid = appid
      else
        return
      end

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
end
