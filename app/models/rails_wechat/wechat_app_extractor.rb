module RailsWechat::WechatAppExtractor
  extend ActiveSupport::Concern
  included do
    belongs_to :extractor
    belongs_to :wechat_app
  end
  
end
