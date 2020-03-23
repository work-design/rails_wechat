module RailsWechat::WechatRequestReply
  extend ActiveSupport::Concern

  included do
    attribute :body, :json

    belongs_to :wechat_request
    belongs_to :wechat_reply
  end


end
