module Wechat
  module Model::App
    extend ActiveSupport::Concern

    included do
      attribute :type, :string, default: 'Wechat::PublicApp'
      attribute :name, :string
      attribute :enabled, :boolean, default: true
      attribute :shared, :boolean, default: false, comment: '可与其他或下级机构公用'
      attribute :oauth_enable, :boolean, default: true
      attribute :inviting, :boolean, default: false, comment: '可邀请加入'
      attribute :appid, :string
      attribute :secret, :string
      attribute :token, :string, default: -> { SecureRandom.hex }
      attribute :agentid, :string, comment: '企业微信所用'
      attribute :mch_id, :string, comment: '支付专用、商户号'
      attribute :key, :string, comment: '支付专用'
      attribute :key_v3, :string, comment: '支付通知解密'
      attribute :encrypt_mode, :boolean, default: true
      attribute :encoding_aes_key, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :jsapi_ticket, :string
      attribute :oauth2_state, :string
      attribute :jsapi_ticket_expires_at, :datetime
      attribute :user_name, :string
      attribute :apiclient_cert, :string
      attribute :apiclient_key, :string
      attribute :serial_no, :string
      attribute :domain, :string
      attribute :url_link, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :post_syncs, as: :synced, dependent: :delete_all
      has_many :posts, through: :post_syncs

      has_one :organ_domain, -> { where(default: true) }, class_name: 'Org::OrganDomain', foreign_key: :appid, primary_key: :appid
      has_many :organ_domains, class_name: 'Org::OrganDomain', foreign_key: :appid, primary_key: :appid

      has_one :agency, foreign_key: :appid, primary_key: :appid
      has_many :agencies, foreign_key: :appid, primary_key: :appid
      has_many :scenes, foreign_key: :appid, primary_key: :appid
      has_many :tags, foreign_key: :appid, primary_key: :appid
      has_many :templates, foreign_key: :appid, primary_key: :appid

      scope :enabled, -> { where(enabled: true) }
      scope :shared, -> { where(shared: true) }
      scope :inviting, -> { where(inviting: true) }

      validates :appid, presence: true, uniqueness: true

      before_validation do
        self.encoding_aes_key ||= SecureRandom.alphanumeric(43) if encrypt_mode
      end
    end

    def url
      Rails.application.routes.url_for(controller: 'wechat/wechats', action: 'show', id: self.id, host: host)
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
      Menu.where(parent_id: nil, appid: nil).limit(limit).as_json
    end

    def within_menus
      if organ && organ.respond_to?(:limit_wechat_menu)
        self.menus.limit(organ.limit_wechat_menu).where(parent_id: nil).order(position: :asc).as_json
      else
        self.menus.where(parent_id: nil).order(position: :asc).as_json
      end
    end

    def refresh_access_token
      r = api.token
      if r['access_token']
        store_access_token(r)
      else
        logger.debug "\e[35m  #{r['errmsg']}  \e[0m"
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
      elsif agency
        @api = Wechat::Api::Public.new(agency)
      else
        raise 'Must has secret or under agency'
      end
    end

    def oauth2_qrcode_url(**host_options)
      q = {
        appid: appid,
        redirect_uri: Rails.application.routes.url_for(controller: 'wechat/apps', action: 'show', id: id, **host_options),
        scope: 'snsapi_login',
        response_type: 'code',
        state: SecureRandom.hex(16)
      }

      "https://open.weixin.qq.com/connect/qrconnect?#{q.to_query}#wechat_redirect"
    end

    def sync_tags
      results = api.tags
      results.fetch('tags', []).each do |result|
        tag = tags.find_or_initialize_by(name: result['name'])
        tag.count = result['count']
        tag.tag_id = result['id']
        tag.save
      end
      tags.where(tag_id: nil).each do |tag|
        tag.sync_to_wechat_later
      end
    end

    # 小程序
    def sync_templates
      templates = api.templates
      templates.each do |template|
        template = templates.find_or_initialize_by(template_id: template['priTmplId'])
        template.template_type = template['type']
        template.assign_attributes template.slice('title', 'content', 'example')
        template.save
      end
    end

    # 公众号
    def sync_template_configs
      templates = api.templates
      templates.each do |template|
        template_config = TemplatePublic.new(title: template['title'])
        data_keys = Template.new(content: template['content']).data_keys
        data_keys.each do |key|
          template_config.template_key_words.build(name: key)
        end
        template_config.save
      end
    end

    def template_ids(notifiable_type, *code)
      ids = TemplateConfig.where(notifiable_type: notifiable_type, code: code).pluck(:id)
      templates.where(template_config_id: ids).pluck(:template_id)
    end

    def host
      if oauth_enable
        domain.presence || organ_domain&.identifier || organ_domains.first&.identifier
      end
    end

  end
end
