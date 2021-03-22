module Wechat
  module Model::ResponseRequest
    extend ActiveSupport::Concern

    included do
      attribute :request_type, :string, comment: '用户发送消息类型'
      attribute :appid, :string

      belongs_to :response

      before_validation do
        self.appid = response.appid
      end
    end

  end
end
