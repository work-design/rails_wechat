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
      attribute :userid, :string, index: true
      attribute :reply_body, :json, default: {}
      attribute :reply_encrypt, :json, default: {}
      attribute :init_wechat_user, :boolean, default: false
      attribute :init_user_tag, :boolean, default: false

      belongs_to :scene_organ, class_name: 'Org::Organ', optional: true

      belongs_to :receive
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
      belongs_to :corp_user, ->(o) { where(corp_id: o.appid) }, foreign_key: :userid, primary_key: :user_id, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true
      belongs_to :agency, foreign_key: :appid, primary_key: :appid, optional: true

      has_one :platform, through: :receive
      has_one :tag, ->(o) { where(name: o.body) }, foreign_key: :appid, primary_key: :appid
      has_one :user_tag, ->(o) { where(tag_name: o.body, open_id: o.open_id) }, foreign_key: :appid, primary_key: :appid
      has_many :services, dependent: :nullify
      has_many :extractions, -> { order(id: :asc) }, dependent: :delete_all, inverse_of: :request  # 解析 request body 内容，主要针对文字
      has_many :request_responses, ->(o) { where(appid: o.appid) }, foreign_key: :request_type, primary_key: :type
      has_many :responses, through: :request_responses

      before_validation :set_body, if: -> { receive.present? }
      before_create :check_wechat_user
      after_create :get_reply!
    end

    def set_body
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.body = self.event_key
    end

    def reply_params(title:, description:, url:)
      if scene_organ && scene_organ.logo.attached?
        head_url = scene_organ.logo.url
      elsif agency
        head_url = agency.head_img
      else
        head_url = ApplicationController.helpers.image_path('logo_avatar.png', protocol: 'https')
      end

      r = {
        appid: appid,
        news_reply_items_attributes: [
          {
            title: title,
            description: description,
            url: url,
            raw_pic_url: head_url
          }
        ]
      }
      Wechat::NewsReply.new(r)
    end

    def reply_params_detail
      url = Rails.application.routes.url_for(controller: 'home', action: 'index', host: app.domain)
      if wechat_user.attributes['name'].present?
        title = "您好，#{wechat_user.attributes['name']}"
        if wechat_user.user
          description = '欢迎您回来'
        else
          description = '您还未完成注册，请点击链接完成'
        end
      elsif ['Wechat::PublicApp'].include?(app.type) && wechat_user.attributes['name'].blank?

      elsif wechat_user.user.blank?

      else
        title = '欢迎您'
        description = '开始使用'
      end

      if app.respond_to?(:weapp) && app.weapp
        url = app.weapp.api.generate_url('/pages/index/index')
      end

      [title, description, url]
    end

    def reply_for_blank_info
      return if wechat_user.attributes['name'].present?
      if agency
        url = agency.oauth2_url(scope: 'snsapi_userinfo', state: agency.base64_state(uid: open_id))
      elsif app&.oauth_enable
        url = app.oauth2_url(scope: 'snsapi_userinfo', state: app.base64_state(uid: open_id))
      else
        return
      end

      reply_params(
        title: '授权信息（微信昵称，头像）',
        description: '相关信息将用于您个人中心的用户展示',
        url: url
      )
    end

    def reply_for_user
      if scene_organ && wechat_user.persisted?
        url = Rails.application.routes.url_for(
          controller: scene_organ.redirect_controller,
          action: scene_organ.redirect_action,
          host: scene_organ.domain,
          auth_token: wechat_user.auth_token
        )
        desc = "#{scene_organ.name}欢迎您\n点击链接访问精心为您准备的内容"
      elsif wechat_user.persisted?
        url = Rails.application.routes.url_for(
          controller: 'my/home',
          host: app&.domain,
          auth_token: wechat_user.auth_token
        )
        desc = '点击链接查看详情'
        return
      else
        return
      end

      reply_params(
        title: wechat_user.attributes['name'].present? ? "您好，#{wechat_user.attributes['name']}" : '您好',
        description: desc,
        url: url
      )
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

    def check_wechat_user
      wechat_user || build_wechat_user
      wechat_user.appid = appid
      if ['SCAN', 'subscribe'].include?(event)
        if body.to_s.start_with?('auth_user_')
          wechat_user.user_inviter_id ||= body.delete_prefix('auth_user_')
          self.scene_organ_id = body.split('_')[-1]
        elsif body.to_s.start_with? 'org_member_'
          wechat_user.member_inviter_id ||= body.delete_prefix('org_member_')
          self.scene_organ_id = body.split('_')[-1]
        end
      end
      if ['subscribe'].include?(event)
        wechat_user.unsubscribe_at = nil
      end

      if wechat_user.new_record?
        self.init_wechat_user = true
      else
        wechat_user.save
      end
    end

    def sync_to_tag
      return if body.blank?
      tag || build_tag
      user_tag || build_user_tag

      if user_tag.new_record?
        self.init_user_tag = true
      end
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        Array(rule[:msg_type]).include?(msg_type) &&
          (rule[:event].blank? || Array(rule[:event]).include?(event&.downcase)) &&
          (rule[:body].blank? || rule[:body].match?(self.body))
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

    def get_reply!
      get_reply
      save
    end

    def get_reply
      reply = reply_from_rule || reply_from_response || reply_for_user

      if reply.is_a?(Reply)
        self.reply_body = reply.to_wechat
        self.reply_body.merge!(ToUserName: open_id)
        self.reply_body.merge!(FromUserName: app&.user_name.presence || agency&.user_name)
      else
        self.reply_body = {}
      end
      do_encrypt
    end

    def login_user
      session_str, url = body.split('@')
      session = session_str.delete_prefix!('session_')

      wechat_user.user || wechat_user.create_user
      wechat_user.save
      Com::SessionChannel.broadcast_to session, auth_token: wechat_user.auth_token, url: url
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
