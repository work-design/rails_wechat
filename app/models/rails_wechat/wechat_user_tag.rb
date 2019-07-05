module RailsWechat::WechatUserTag
  extend ActiveSupport::Concern
  included do
    belongs_to :wechat_user
    belongs_to :wechat_tag
  end

 
  
end

