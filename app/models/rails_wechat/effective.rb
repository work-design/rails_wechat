module RailsWechat::Effective
  extend ActiveSupport::Concern
  included do
    has_one :wechat_response, as: :effective
  end
  
  def invoke_effect(wechat_user)
    p 'please implement in class'
  end
  
end
