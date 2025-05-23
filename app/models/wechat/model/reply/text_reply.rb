module Wechat
  module Model::Reply::TextReply

    included do
      after_create_commit :msg_send
    end

    def msg_type
      'text'
    end

    def content
      {
        MsgType: 'text',
        Content: value
      }
    end

    def msg_send
      r = app.api.message_custom_send(
        touser: open_id,
        msgtype: msg_type,
        text: {
          content: content
        }
      )
      logger.debug r
    end

    def add_to_log
      self.message_sends.create(
        appid: appid,
        content: msg
      )
    end

  end
end
