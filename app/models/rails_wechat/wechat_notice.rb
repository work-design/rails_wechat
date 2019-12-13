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
    nt = notifiable_type.constantize
    if nt.respond_to?(:notifies)
      r = nt.notifies
      Hash(r[self.code.to_sym]).fetch(:only, []).map(&->(o){ [nt.human_attribute_name(o), o] }).to_h
    else
      {}
    end
  end

end
