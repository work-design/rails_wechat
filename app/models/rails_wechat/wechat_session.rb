module RailsWechat::WechatSession
  extend ActiveSupport::Concern
  included do
    validates :openid, presence: true, uniqueness: true
  end

  # called by wechat gems after response Techent server at controller#create
  def save_session(_response_message)
    touch unless new_record? # Always refresh updated_at even no change
    save!
  end
  
  class_methods do
    def find_or_initialize_session(request_message)
      find_or_initialize_by(openid: request_message[:from_user_name])
    end
  end
  
end
