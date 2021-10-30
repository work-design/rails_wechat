module Wechat
  module Model::Reply::VoiceReply

    def content
      {
        MsgType: 'voice',
        Voice: { MediaId: value }
      }
    end

  end
end
