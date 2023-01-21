module Wechat
  module Model::Reply::MusicReply

    def msg_type
      'music'
    end

    def content
      {
        MsgType: 'music',
        Music: {
          ThumbMediaId: value,
          Title: title,
          Description: description
        }
      }
    end

  end
end
