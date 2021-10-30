module Wechat
  module Model::Reply::TextReply

    def content
      {
        MsgType: 'text',
        Content: value
      }
    end

  end
end
