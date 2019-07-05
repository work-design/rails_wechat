module RailsWechat::WechatUser
  extend ActiveSupport::Concern
  included do
    has_many :wechat_requests, dependent: :delete_all
    has_many :ticket_items, dependent: :delete_all
    has_many :wechat_user_tags, dependent: :destroy
    has_many :wechat_tags, through: :wechat_user_tags
  end
  
end
