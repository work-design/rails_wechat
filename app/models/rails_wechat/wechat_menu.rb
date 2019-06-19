module RailsWechat::WechatMenu
  extend ActiveSupport::Concern
  included do
    acts_as_list
    
    belongs_to :wechat_config, optional: true
    belongs_to :parent, class_name: self.name, optional: true
  end
  
  
end
