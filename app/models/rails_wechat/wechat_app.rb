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
    attribute :help, :string, limit: 1024, default: '', comment: '默认帮助'
    attribute :help_without_user, :string, default: '请绑定账号，输入"绑定"根据提示操作', comment: '未注册用户提示'
    attribute :help_feedback, :string, default: '你的反馈已收到', comment: '正常发送反馈内容回复'
    attribute :access_token, :string
    attribute :access_token_expires_at, :datetime
    attribute :jsapi_ticket, :string
    attribute :jsapi_ticket_expires_at, :datetime
    
    belongs_to :organ, optional: true
    has_many :wechat_menus, dependent: :destroy
    has_many :text_responses, dependent: :destroy
    has_many :scan_responses, dependent: :destroy
    has_many :wechat_responses, dependent: :destroy
    has_many :wechat_requests, dependent: :nullify
    has_many :wechat_tags, dependent: :delete_all
    
    has_many :wechat_app_extractors, dependent: :delete_all
    has_many :extractors, through: :wechat_app_extractors
    
    has_many :wechat_users, foreign_key: :app_id, primary_key: :appid
    
    scope :valid, -> { where(enabled: true) }
    
    validates :name, presence: true
    validates :appid, presence: true, uniqueness: true
    validates :secret, presence: true
    validates :token, presence: true

    before_validation do
      self.encoding_aes_key ||= SecureRandom.alphanumeric(43) if encrypt_mode
    end
    after_save :set_primary, if: -> { self.primary? && saved_change_to_primary? }
  end
  
  def url
    url_helpers.wechat_url(self.id)
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
    WechatMenu.where(parent_id: nil).limit(limit).as_json
  end
  
  def within_menus
    if organ
      self.wechat_menus.limit(organ.limit_wechat_menu).where(parent_id: nil).as_json
    else
      self.wechat_menus.where(parent_id: nil).as_json
    end
  end
  
  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

  def jsapi_ticket_valid?
    return false unless jsapi_ticket_expires_at.acts_like?(:time)
    jsapi_ticket_expires_at > Time.current
  end

  def set_primary
    q = {}
    if self.class.column_names.include?('organ_id')
      q.merge! organ_id: self.organ_id
    end
    
    self.class.base_class.unscoped.where.not(id: self.id).where(q).update_all(primary: false)
  end
  
  def match_values
    text_responses.map(&:match_value).join('|')
  end
  
  def api
    Wechat.app_api(self)
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
  
  class_methods do
    
    def default
      q = {}
      if column_names.include?('organ_id')
        q.merge! organ_id: nil
      end
      where(q).valid.find_by(primary: true)
    end
    
  end
  
end
