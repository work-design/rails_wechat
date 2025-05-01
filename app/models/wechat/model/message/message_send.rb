module Wechat
  module Model::Message::MessageSend
    extend ActiveSupport::Concern

    included do
      after_create_commit :msg_send
    end

    def msg_send
      r = app.api.message_custom_send(
        touser: open_id,
        msgtype: 'text',
        text: {
          content: content
        }
      )
      logger.debug r
    end

  end
end
