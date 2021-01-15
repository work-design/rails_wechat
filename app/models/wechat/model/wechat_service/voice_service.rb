module Wechat
  module RailsWechat::WechatService::VoiceService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'voice'
    end

  end
end
