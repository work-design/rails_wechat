module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'
    attribute :mappings, :json
    
    belongs_to :wechat_template
    has_many :wechat_subscribeds
  end
  
  

end
