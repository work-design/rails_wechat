module RailsWechat::WechatApp
  extend ActiveSupport::Concern

  included do
    delegate :url_helpers, to: 'Rails.application.routes'

    attribute :type, :string, default: 'WechatPublic'
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

    belongs_to :organ, optional: true
    has_many :wechat_tags, dependent: :delete_all
    has_many :wechat_templates, dependent: :destroy
    has_many :post_syncs, as: :synced, dependent: :delete_all
    has_many :posts, through: :post_syncs

    scope :valid, -> { where(enabled: true) }

    validates :appid, presence: true, uniqueness: true

    before_validation do
      self.encoding_aes_key ||= SecureRandom.alphanumeric(43) if encrypt_mode
    end
    after_save :set_primary, if: -> { self.primary? && saved_change_to_primary? }
  end

  def url
    url_helpers.wechat_url(self.id)
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
    if organ
      limit = 3 - organ.limit_wechat_menu
    else
      limit = 3
    end
    WechatMenu.where(parent_id: nil, appid: nil).limit(limit).as_json
  end

  def within_menus
    if organ
      self.wechat_menus.limit(organ.limit_wechat_menu).where(parent_id: nil).order(position: :asc).as_json
    else
      self.wechat_menus.where(parent_id: nil).order(position: :asc).as_json
    end
  end

  def refresh_access_token
    r = api.token
    store_access_token(r)
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

  def set_primary
    q = {}
    if self.class.column_names.include?('organ_id')
      q.merge! organ_id: self.organ_id
    end

    self.class.unscoped.where.not(id: self.id).where(q).update_all(primary: false)
  end

  def api
    return @api if defined? @api
    @api = Wechat::Api::Public.new(self)
  end

  def generate_oauth2_url(oauth2_params)
    if oauth2_params[:scope] == 'snsapi_login'
      "https://open.weixin.qq.com/connect/qrconnect?#{oauth2_params.to_query}#wechat_redirect"
    else
      "https://open.weixin.qq.com/connect/oauth2/authorize?#{oauth2_params.to_query}#wechat_redirect"
    end
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

  def subdomain
    [['app', organ_id, id].join('-'), RailsCom.config.subdomain].compact.join('.')
  end

  class_methods do

    def default(params = {})
      q = params.dup
      app = default_where(q).valid.find_by(primary: true)
      if app
        app
      else
        default_where(organ_id: nil, allow: { organ_id: nil }).valid.find_by(primary: true)
      end
    end

  end

end
