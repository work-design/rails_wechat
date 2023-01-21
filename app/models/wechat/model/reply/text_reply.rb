module Wechat
  module Model::Reply::TextReply

    def msg_type
      'text'
    end

    def content
      {
        MsgType: 'text',
        Content: value
      }
    end

  end
end
