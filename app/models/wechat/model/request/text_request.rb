module Wechat
  module Model::Request::TextRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :send_message, :auto_reply
    end

    def send_message
      Turbo::StreamsChannel.broadcast_action_to(
        wechat_user,
        action: :append,
        target: 'chat_box',
        partial: 'wechat/panel/wechat_users/message',
        locals: { model: receive, wechat_user: wechat_user }
      )
    end

    def auto_reply
      if wechat_user.respond_to?(:auto_reply) && wechat_user.auto_reply && defined? OneAi
        app = OneAi::App.first
        content = app.chat(self.body)
        text_reply = create_text_reply(value: content)

        Turbo::StreamsChannel.broadcast_action_to(
          wechat_user,
          action: :append,
          target: 'chat_box',
          partial: 'wechat/panel/wechat_users/message',
          locals: { model: text_reply, wechat_user: wechat_user }
        )
      end
    end

    def set_body
      self.body = raw_body['Content']
    end

    def reply_from_response
      res = responses.find(&->(r){ r.scan_regexp(body) })
      res.invoke_effect(self) if res
    end

  end
end
