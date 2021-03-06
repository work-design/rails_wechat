module Wechat
  module Model::Service::TextService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'text'
    end

    def content
      {
        text: {
          content: value
        }
      }
    end

  end
end
