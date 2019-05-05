module RailsWechat::WechatConfig
  extend ActiveSupport::Concern
  included do
    attribute :environment, :string, default: -> { Rails.env }
    attribute :help, :string, default: ''
    attribute :help_without_user, :string, default: '请注册后使用'
    attribute :help_user_disabled, :string, default: '你没有权限'
    
    has_many :wechat_menus, dependent: :destroy
    has_many :wechat_responses, dependent: :destroy
    has_many :wechat_feedbacks, dependent: :nullify
    
    has_many :extractors
    
    validates :environment, presence: true
    validates :account, presence: true, uniqueness: { scope: [:environment] }
    validates :token, presence: true
    validates :encoding_aes_key, presence: { if: :encrypt_mode? }

    validate :app_config_is_valid
  end

  class_methods do
    def get_all_configs(environment)
      WechatConfig.where(environment: environment, enabled: true).inject({}) do |hash, config|
        hash[config.account] = config.build_config_hash
        hash
      end
    end
  end
  
  def menu
    {
      button: self.wechat_menus.as_json
    }
  end
  
  def match_values
    wechat_responses.where(type: ['TextResponse']).map(&:match_value).join('|')
  end

  def build_config_hash
    self.as_json(except: [:environment, :account, :created_at, :updated_at, :enabled])
  end

  private
  def app_config_is_valid
    if self[:appid].present?
      # public account
      if self[:secret].blank?
        errors.add(:secret, 'cannot be nil when appid is set')
      end
    elsif self[:corpid].present?
      # corp account
      if self[:corpsecret].blank?
        errors.add(:corpsecret, 'cannot be nil when corpid is set')
      end
      if self[:agentid].blank?
        errors.add(:agentid, 'cannot be nil when corpid is set')
      end
    else
      errors[:base] << 'Either appid or corpid must be set'
    end
  end
  
end
