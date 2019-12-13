module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'
    attribute :mappings, :json, default: {}
    
    belongs_to :wechat_template
    has_many :wechat_subscribeds
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
