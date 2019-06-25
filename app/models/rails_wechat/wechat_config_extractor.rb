module RailsWechat::WechatConfigExtractor
  extend ActiveSupport::Concern
  included do
    belongs_to :extractor
    belongs_to :wechat_config
  end
  
end
