module RailsWechat::WechatMenu
  extend ActiveSupport::Concern
  included do
    belongs_to :wechat_config
  end
  
  
end
