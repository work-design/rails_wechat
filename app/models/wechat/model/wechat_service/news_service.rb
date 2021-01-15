module Wechat
  module RailsWechat::WechatService::NewsService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'news'
    end

  end
end
