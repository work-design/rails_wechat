module Wechat
  module Model::Reply::MusicReply

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
