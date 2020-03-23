module RailsWechat::WechatResponseExtractor
  extend ActiveSupport::Concern

  included do
    belongs_to :wechat_response
    belongs_to :extractor
  end

end
