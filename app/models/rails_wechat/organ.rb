module RailsWechat::Organ
  extend ActiveSupport::Concern
  included do
    has_one :wechat_config, dependent: :destroy
  end
  
  def wechat_config
    super || build_wechat_config
  end
  
end
