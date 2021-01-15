module Wechat
  module RailsWechat::WechatService::ImageService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'image'
    end

    def content
      {
        image: {
          media_id: value
        }
      }
    end

  end
end
