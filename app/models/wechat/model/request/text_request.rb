module Wechat
  module Model::Request::TextRequest
    extend ActiveSupport::Concern

    included do
      after_create_commit :send_message
    end

    def send_message
      Turbo::StreamsChannel.broadcast_action_to(
        wechat_user,
        action: :append,
        target: 'chat_box',
        partial: 'wechat/panel/wechat_users/_base/message',
        locals: { model: receive, wechat_user: wechat_user }
      )
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
