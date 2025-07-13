module Wechat
  module Model::Request
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :body, :string
      attribute :tag_name, :string
      attribute :raw_body, :json
      attribute :msg_type, :string
      attribute :event, :string
      attribute :event_key, :string
      attribute :appid, :string, index: true
      attribute :open_id, :string, index: true
      attribute :userid, :string, index: true
      attribute :handle_id, :integer
      attribute :reply_body, :json

      enum :aim, {
        login: 'login',
        invite_user: 'invite_user',
        invite_member: 'invite_member',
        invite_contact: 'invite_contact',
        prepayment: 'prepayment',  # 钱包充值场景
        unknown: 'unknown'
      }, default: 'unknown', prefix: true

      belongs_to :scene_organ, class_name: 'Org::Organ', optional: true

      belongs_to :receive
      belongs_to :platform, optional: true
      belongs_to :wechat_user, foreign_key: :open_id, primary_key: :uid, optional: true
      belongs_to :corp_user, ->(o) { where(corp_id: o.appid) }, foreign_key: :userid, primary_key: :user_id, optional: true
      belongs_to :app, foreign_key: :appid, primary_key: :appid, optional: true

      has_one :tag, ->(o) { where(name: o.tag_name) }, primary_key: :appid, foreign_key: :appid
      has_one :user_tag, ->(o) { where(tag_name: o.tag_name, open_id: o.open_id) }, primary_key: :appid, foreign_key: :appid
      has_one :scene, primary_key: :body, foreign_key: :match_value
      has_one :reply, ->(o) { where(open_id: o.open_id, appid: o.appid, platform_id: o.platform_id) }
      has_one :text_reply, ->(o) { where(open_id: o.open_id, appid: o.appid, platform_id: o.platform_id) }
      has_one :news_reply, ->(o) { where(open_id: o.open_id, appid: o.appid, platform_id: o.platform_id) }
      has_one :empty_reply, ->(o) { where(open_id: o.open_id, appid: o.appid, platform_id: o.platform_id) }

      has_many :services, dependent: :nullify
      has_many :extractions, -> { order(id: :asc) }, dependent: :delete_all, inverse_of: :request  # 解析 request body 内容，主要针对文字
      has_many :request_responses, ->(o) { where(appid: o.appid) }, foreign_key: :request_type, primary_key: :type
      has_many :responses, through: :request_responses

      before_validation :set_body
      before_create :check_wechat_user_and_tag
      before_save :sync_to_tag, if: -> { tag_name.present? && tag_name_changed? }
    end

    def set_body
      self.event_key = raw_body['EventKey'] || raw_body.dig('ScanCodeInfo', 'ScanResult')
      self.body = self.event_key
    end

    def reply_params(title:, description:, url:)
      if scene_organ && scene_organ.logo.attached?
        head_url = scene_organ.logo.url
      elsif app
        head_url = app.head_img
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
      build_news_reply(r)
    end

    def reply_params_detail
      url = Rails.application.routes.url_for(
        controller: 'home',
        action: 'index',
        host: app.domain
      )
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
      if app
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
        url = scene_organ.redirect_url(auth_token: wechat_user.auth_token)
        desc = "#{scene_organ.name}欢迎您\n点击链接访问精心为您准备的内容"
      elsif wechat_user.persisted?
        url = Rails.application.routes.url_for(
          controller: 'my/home',
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

    def reply_for_login
      if wechat_user.unionid.present?
        wechat_user.login!(scene.state_uuid)
        build_text_reply(value: '登录成功！')
      else
        reply_params(
          title: '您好，点击链接授权登录',
          description: '点击授权',
          url: app.oauth2_url(state: scene.state_uuid, action: 'scan_login')
        )
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

    def check_wechat_user_and_tag
      if event_key&.start_with?('qrscene_')
        scene_tag = event_key.delete_prefix('qrscene_')
      else
        scene_tag = nil
      end
      wechat_user || build_wechat_user(scene_tag: scene_tag)
      wechat_user.appid = appid
      if ['SCAN', 'subscribe'].include?(event) && body.to_s.start_with?('invite_')
        invite_user!
      elsif ['SCAN', 'subscribe'].include?(event) && body.to_s.start_with?('session_')
        wechat_user.init_user
        wechat_user.save
      end
    end

    def sync_to_tag
      tag || build_tag
      user_tag || build_user_tag
    end

    def invite_user!
      _handle_id, _organ_id, _tag_name = body.sub(/invite_(user|member|contact)_/, '').split('_')

      if body.to_s.start_with?('invite_user_')
        self.aim = 'invite_user'
      elsif body.to_s.start_with? 'invite_member_'
        self.aim = 'invite_member'
        wechat_user.init_member(_organ_id)
      elsif body.to_s.start_with? 'invite_contact_'
        self.aim = 'invite_contact'
        wechat_user.init_contact(_organ_id, _handle_id)
      end

      self.handle_id = _handle_id
      self.scene_organ_id = _organ_id
      self.tag_name = _tag_name
      wechat_user.save
    end

    def reply_from_rule
      filtered = RailsWechat.config.rules.find do |_, rule|
        Array(rule[:msg_type]).include?(msg_type) &&
          (rule[:event].blank? || Array(rule[:event]).include?(event&.downcase)) &&
          (rule[:body].blank? || rule[:body].match?(self.body))
      end

      filtered[1][:proc].call(self) if filtered.present?
    end

    def to_reply!
      reply = if ['SCAN', 'subscribe'].include?(event) && body.to_s.start_with?('session_')
        reply_for_login
      else
        reply_from_rule || reply_from_response || reply_for_user
      end

      if reply
        self.reply_body = reply.reply_body
        self.save
      else
        reply = build_empty_reply
      end
      reply
    end

  end
end
