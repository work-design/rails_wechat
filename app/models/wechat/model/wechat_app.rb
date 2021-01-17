module Wechat
  module Model::WechatApp
    extend ActiveSupport::Concern

    included do
      delegate :url_helpers, to: 'Rails.application.routes'

      attribute :type, :string, default: 'Wechat::WechatPublic'
      attribute :name, :string
      attribute :enabled, :boolean, default: true
      attribute :primary, :boolean, default: false
      attribute :appid, :string
      attribute :secret, :string
      attribute :token, :string, default: -> { SecureRandom.hex }
      attribute :agentid, :string, comment: '企业微信所用'
      attribute :mch_id, :string, comment: '支付专用、商户号'
      attribute :key, :string, comment: '支付专用'
      attribute :encrypt_mode, :boolean, default: true
      attribute :encoding_aes_key, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :jsapi_ticket, :string
      attribute :oauth2_state, :string
      attribute :jsapi_ticket_expires_at, :datetime
      attribute :user_name, :string
      attribute :oauth_enable, :boolean, default: true
      attribute :apiclient_cert, :string
      attribute :apiclient_key, :string

      belongs_to :organ, optional: true
      has_many :wechat_tags, dependent: :delete_all
      has_many :wechat_templates, dependent: :destroy
      has_many :post_syncs, as: :synced, dependent: :delete_all
      has_many :posts, through: :post_syncs
      has_many :organ_domains, foreign_key: :appid, primary_key: :appid
      has_one :wechat_agency, foreign_key: :appid, primary_key: :appid
      has_many :wechat_agencies, foreign_key: :appid, primary_key: :appid

      scope :valid, -> { where(enabled: true) }

      validates :appid, presence: true, uniqueness: true

      before_validation do
        self.encoding_aes_key ||= SecureRandom.alphanumeric(43) if encrypt_mode
      end
    end

    def url
      url_helpers.wechat_url(self.id, host: host)
    end

    def sync_menu
      api.menu_delete
      api.menu_create menu
    end

    def menu
      {
        button: default_menus + within_menus
      }
    end

    def default_menus
      if organ && organ.respond_to?(:limit_wechat_menu)
        limit = 3 - organ.limit_wechat_menu
      else
        limit = 3
      end
      WechatMenu.where(parent_id: nil, appid: nil).limit(limit).as_json
    end

    def within_menus
      if organ && organ.respond_to?(:limit_wechat_menu)
        self.wechat_menus.limit(organ.limit_wechat_menu).where(parent_id: nil).order(position: :asc).as_json
      else
        self.wechat_menus.where(parent_id: nil).order(position: :asc).as_json
      end
    end

    def refresh_access_token
      r = api.token
      if r['access_token']
        store_access_token(r)
      else
        logger.debug "  ==========> #{r['errmsg']}"
      end
    end

    def store_access_token(token_hash)
      self.access_token = token_hash['access_token']
      self.access_token_expires_at = Time.current + token_hash['expires_in'].to_i
      self.save
    end

    def jsapi_ticket
      if jsapi_ticket_valid?
        super
      else
        refresh_jsapi_ticket
      end
    end

    def jsapi_ticket_valid?
      return false unless jsapi_ticket_expires_at.acts_like?(:time)
      jsapi_ticket_expires_at > Time.current
    end

    def refresh_jsapi_ticket
      r = api.jsapi_ticket
      store_jsapi_ticket(r)
      jsapi_ticket
    end

    def store_jsapi_ticket(ticket_hash)
      self.jsapi_ticket = ticket_hash['ticket']
      self.jsapi_ticket_expires_at = Time.current + ticket_hash['expires_in'].to_i
      self.save
    end

    def api
      return @api if defined? @api
      if secret.present?
        @api = Wechat::Api::Public.new(self)
      elsif wechat_agency
        @api = Wechat::Api::Public.new(wechat_agency)
      else
        @api = nil
      end
    end

    def oauth2_qrcode_url
      q = {
        appid: appid,
        redirect_uri: url_helpers.wechat_app_url(id, **host_options),
        scope: 'snsapi_login',
        response_type: 'code',
        state: SecureRandom.hex(16)
      }

      "https://open.weixin.qq.com/connect/qrconnect?#{q.to_query}#wechat_redirect"
    end

    def sync_wechat_tags
      tags = api.tags
      tags.fetch('tags', []).each do |tag|
        wechat_tag = wechat_tags.find_or_initialize_by(name: tag['name'])
        wechat_tag.count = tag['count']
        wechat_tag.tag_id = tag['id']
        wechat_tag.save
      end
    end

    # 小程序
    def sync_wechat_templates
      templates = api.templates
      templates.each do |template|
        wechat_template = wechat_templates.find_or_initialize_by(template_id: template['priTmplId'])
        wechat_template.template_type = template['type']
        wechat_template.assign_attributes template.slice('title', 'content', 'example')
        wechat_template.save
      end
    end

    # 公众号
    def sync_template_configs
      templates = api.templates
      templates.each do |template|
        template_config = TemplatePublic.new(title: template['title'])
        data_keys = WechatTemplate.new(content: template['content']).data_keys
        data_keys.each do |key|
          template_config.template_key_words.build(name: key)
        end
        template_config.save
      end
    end

    def template_ids(notifiable_type, *code)
      ids = TemplateConfig.where(notifiable_type: notifiable_type, code: code).pluck(:id)
      wechat_templates.where(template_config_id: ids).pluck(:template_id)
    end

    def host
      if oauth_enable
        organ_domains.first&.identifier
      end
    end

  end
end
