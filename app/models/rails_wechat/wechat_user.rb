module RailsWechat::WechatUser
  extend ActiveSupport::Concern
  included do
    has_many :wechat_feedbacks, dependent: :delete_all
  end
  
  class_methods do
    def init_wechat_user(request)
      wechat_user = WechatUser.find_or_create_by(uid: request[:FromUserName])
    end
  end
  
end
