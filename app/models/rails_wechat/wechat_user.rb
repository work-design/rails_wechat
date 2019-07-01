module RailsWechat::WechatUser
  extend ActiveSupport::Concern
  included do
    has_many :wechat_requests, dependent: :delete_all
    has_many :ticket_items, dependent: :delete_all
  end
  
end
