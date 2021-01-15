module Wechat
  module Model::WechatService::NewsService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'news'
    end

  end
end
