module Wechat
  module Model::Service::ImageService
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
