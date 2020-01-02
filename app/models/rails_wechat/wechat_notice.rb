module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    
    belongs_to :public_template
    belongs_to :wechat_app
    has_many :wechat_subscribeds
    
    before_validation do
      self.wechat_app = wechat_template.wechat_app
    end
  end

  

end
