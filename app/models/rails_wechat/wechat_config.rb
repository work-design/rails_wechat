module RailsWechat::WechatConfig
  extend ActiveSupport::Concern
  included do
    attribute :environment, :string, default: -> { Rails.env }
    attribute :account, :string
    attribute :appid, :string
    attribute :secret, :string
    attribute :agentid, :string
    attribute :token, :string, default: -> { SecureRandom.hex }
    attribute :encoding_aes_key, :string, default: -> { SecureRandom.alphanumeric(43) }
    attribute :help, :string, default: ''
    attribute :help_without_user, :string, default: '请注册后使用'
    attribute :help_user_disabled, :string, default: '你没有权限'
    attribute :help_feedback, :string, default: '你的反馈已收到'
    attribute :access_token, :string
    attribute :jsapi_ticket, :string
    attribute :type, :string, default: 'WechatPublic'
    
    has_many :wechat_menus, dependent: :destroy
    has_many :text_responses, dependent: :destroy
    has_many :scan_responses, dependent: :destroy
    has_many :wechat_responses, dependent: :destroy
    has_many :wechat_feedbacks, dependent: :nullify
    
    has_many :extractors
    
    scope :valid, -> { where(enabled: true, environment: Rails.env.to_s) }
    
    validates :environment, presence: true
    validates :account, presence: true, uniqueness: { scope: [:environment] }
    validates :token, presence: true
    validates :encoding_aes_key, presence: { if: :encrypt_mode? }
    validates :appid, presence: true
    validates :secret, presence: true
  end
  
  def menu
    {
      button: self.wechat_menus.as_json
    }
  end
  
  def access_token_valid?
    return false unless access_token_expires_at.acts_like?(:time)
    access_token_expires_at > Time.current
  end

  def jsapi_ticket_valid?
    return false unless jsapi_ticket_expires_at.acts_like?(:time)
    jsapi_ticket_expires_at > Time.current
  end
  
  def match_values
    text_responses.map(&:match_value).join('|')
  end
  
end
