module Wechat
  module Model::Reply::VideoReply

    def content
      {
        MsgType: 'video',
        Video: {
          MediaId: value,
          Title: title,
          Description: description
        }
      }
    end

  end
end
