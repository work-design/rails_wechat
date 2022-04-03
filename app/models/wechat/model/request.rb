module Wechat
  module Model::Request
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :body, :string
      attribute :raw_body, :json
      attribute :msg_type, :string
      attribute :event, :string
      attribute :event_key, :string
      attribute :appid, :string, index: true
      attribute :open_id, :string, index: true
      attribute :reply_body, :json, default: {}
      attribute :reply_encrypt, :json, default: {}
      attribute :init_wechat_user, :boolean, default: false
      attribute :init_user_tag, :boolean, default: false

      belongs_to :receive
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      has_one :platform, through: :receive
      has_one :tag, ->(o){ where(name: o.body) }, foreign_key: :appid, primary_key: :appid
      has_one :user_tag, ->(o){ where(tag_name: o.body, open_id: o.open_id) }, foreign_key: :appid, primary_key: :appid
      has_many :services, dependent: :nullify
      has_many :extractions, -> { order(id: :asc) }, dependent: :delete_all, inverse_of: :request  # 解析 request body 内容，主要针对文字
      has_many :request_responses, foreign_key: :request_type, primary_key: :type
      has_many :responses, through: :request_responses

      before_validation :set_body, if: -> { receive.present? }
      after_create :get_reply!
    end

    def set_body
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.body = self.event_key
    end

    def rule_tag
      {
        msg_type: msg_type,
        event: event&.downcase,
        event_key: event_key
      }.compact
    end

    def reply_params
      params = reply_params_detail

      {
        appid: appid,
        news_reply_items_attributes: [
          {
            title: params[0],
            description: params[1],
            url: params[2],
            raw_pic_url: ApplicationController.helpers.image_path('logo_avatar.jpg', protocol: 'https')
          }
        ]
      }
    end

    def reply_params_detail
      url = Rails.application.routes.url_for(controller: 'home', action: 'index')
      if wechat_user.attributes['name'].present?
        title = "您好，#{wechat_user.attributes['name']}"
        if wechat_user.user
          description = '欢迎您回来'
        else
          description = '您还未完成注册，请点击链接完成'
        end
      elsif wechat_user.attributes['name'].blank?
        title = '授权您的信息（微信昵称，头像）'
        description = '您的信息将被用于个人中心的用户展示'
        url = app.oauth2_url
      elsif wechat_user.user.blank?
        title = '请绑定'
        description = '绑定已有账号或注册新账号'
        url = Rails.application.routes.url_for(controller: 'auth/sign', action: 'sign', uid: open_id, host: app.host)
      else
        title = '欢迎您'
        description = '开始使用'
      end

      if app.weapp
        url = app.weapp.api.generate_url('/pages/index/index')
      end

      [title, description, url]
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        if rule.slice(:msg_type, :event, :event_key) <= self.rule_tag && rule[:body]
          rule[:body].match? self.body
        end
      end

      if filtered.present?
        logger.debug "\e[35m  Filter Key: #{filtered[1]}  \e[0m"
        r = filtered[1][:proc].call(self)
        if r.has_content?
          r
        end
      end
    end

    def reply_from_response
      if body.present?
        res = responses.find_by(match_value: body)
      else
        res = responses[0]
      end

      res.invoke_effect(self) if res
    end

    # Typing
    # CancelTyping
    def typing(command = 'Typing')
      app.api.message_custom_typing(wechat_user.uid, command)
    end

    def generate_wechat_user
      wechat_user || build_wechat_user
      wechat_user.appid = appid
      if ['SCAN', 'subscribe'].include?(event)
        if body.to_s.start_with?('invite_by_')
          wechat_user.user_inviter_id = body.delete_prefix('invite_by_')
        elsif body.to_s.start_with? 'invite_member_'
          wechat_user.member_inviter_id = body.delete_prefix('invite_member_')
        end
      end

      if wechat_user.new_record?
        self.init_wechat_user = true
      end
    end

    def sync_to_tag
      tag || build_tag
      user_tag || build_user_tag

      if user_tag.new_record?
        self.init_user_tag = true
      end
    end

    def get_reply!
      get_reply
      save
    end

    def get_reply
      reply = reply_from_rule
      unless reply
        self.created_at ||= Time.current  # for extractor
        reply = reply_from_response
      end

      if reply.is_a?(Reply)
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
        return self.reply_body
      end
      return if self.reply_body.blank?

      nonce = SecureRandom.hex(10)
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
