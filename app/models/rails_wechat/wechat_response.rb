module RailsWechat::WechatResponse
  extend ActiveSupport::Concern
  included do
    attribute :regexp, :string
    
    belongs_to :wechat_config
  end
  
end
