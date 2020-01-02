module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'
    attribute :mappings, :json, default: {}
    
    belongs_to :wechat_template
    belongs_to :wechat_app
    has_many :wechat_subscribeds
    
    before_validation do
      self.wechat_app = wechat_template.wechat_app
    end
  end

  def notify_setting
    r = RailsNotice.notifiable_types.dig(notifiable_type, self.code.to_sym) || {}
    r.fetch(:only, []).map(&->(o){ [notifiable_type.constantize.human_attribute_name(o), o] }).to_h
  end

end
