module Wechat
  module Model::Reply::TextReply
    extend ActiveSupport::Concern

    included do
      after_create_commit :msg_send, :add_to_log
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
      app.api.message_custom_send(
        touser: open_id,
        msgtype: msg_type,
        text: {
          content: value
        }
      )
    end

    def add_to_log
      self.create_message_send(
        appid: appid,
        content: value
      )
    end

  end
end
