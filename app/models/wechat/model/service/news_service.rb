module Wechat
  module Model::Service::NewsService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'news'
    end

  end
end
