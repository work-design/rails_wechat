module Wechat
  module Model::Reply::VoiceReply
    extend ActiveSupport::Concern

    included do
      attribute :msg_type, :string, default: 'voice'
    end

    def content
      {
        Voice: { MediaId: value }
      }
    end

  end
end
