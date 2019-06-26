module RailsWechat::WechatUser
  extend ActiveSupport::Concern
  included do
    has_many :wechat_requests, dependent: :delete_all
    has_many :response_items, dependent: :delete_all
  end
  
end
