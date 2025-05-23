# https://developers.weixin.qq.com/doc/offiaccount/Message_Management/Passive_user_reply_message.html
module Wechat
  module Model::Reply
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :value, :string
      attribute :title, :string
      attribute :description, :string
      attribute :body, :json
      attribute :appid, :string, index: true
      attribute :open_id, :string
      attribute :nonce, :string, default: SecureRandom.hex(10)
      attribute :created_at, :datetime, default: Time.current

      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :messaging, polymorphic: true, optional: true
      belongs_to :request, optional: true

      has_one_attached :media
    end

    def invoke_effect(request = nil, **options)
      self.value = value.to_s + options[:value].to_s
      self
    end

    def has_content?
      value.present?
    end

    def content
      {}
    end

    def to_wechat1
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

    def to_wechat
      r = {
        CreateTime: created_at.to_i,
        ToUserName: open_id
      }
      r.merge!(FromUserName: app.user_name.presence) if app
      r.merge! content
      r
    end

    def real_app
      platform || app
    end

    def do_encrypt
      return self.reply_body unless real_app.encrypt_mode
      return if self.reply_body.blank?
      encrypt = Base64.strict_encode64(Wechat::Cipher.encrypt(Wechat::Cipher.pack(to_xml, real_app.appid), real_app.encoding_aes_key))
      msg_sign = Wechat::Signature.hexdigest(real_app.token, created_at.to_i, nonce, encrypt)

      {
        Encrypt: encrypt,
        MsgSignature: msg_sign,
        TimeStamp: created_at.to_i,
        Nonce: nonce
      }
    end

  end
end
