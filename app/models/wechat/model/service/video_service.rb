module Wechat
  module Model::Service::VideoService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'video'
    end

  end
end
