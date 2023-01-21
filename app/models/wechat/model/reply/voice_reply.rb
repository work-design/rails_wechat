module Wechat
  module Model::Reply::VoiceReply

    def msg_type
      'voice'
    end

    def content
      {
        MsgType: 'voice',
        Voice: { MediaId: value }
      }
    end

  end
end
