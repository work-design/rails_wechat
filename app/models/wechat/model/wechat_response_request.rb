module Wechat
  module RailsWechat::WechatResponseRequest
    extend ActiveSupport::Concern

    included do
      attribute :request_type, :string, comment: '用户发送消息类型'
      attribute :appid, :string

      belongs_to :wechat_response

      before_validation do
        self.appid = wechat_response.appid
      end
    end

  end
end
