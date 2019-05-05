module RailsWechat::WechatResponse
  extend ActiveSupport::Concern
  included do
    attribute :type, :string, default: 'TextResponse'
    attribute :match_value, :string
    
    belongs_to :wechat_config
  end
  
end
