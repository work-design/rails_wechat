module Wechat
  module Model::Service::VoiceService
    extend ActiveSupport::Concern

    included do
      attribute :msgtype, :string, default: 'voice'
    end

  end
end
