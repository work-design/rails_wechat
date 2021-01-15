module Wechat
  module RailsWechat::WechatService::MpnewsService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'mpnews'
    end

  end
end
