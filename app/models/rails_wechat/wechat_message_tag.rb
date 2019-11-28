module RailsWechat::WechatMessageTag
  extend ActiveSupport::Concern
  included do
    belongs_to :wechat_message
    belongs_to :wechat_tag
  end
  
end
