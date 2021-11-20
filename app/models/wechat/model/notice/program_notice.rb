module Wechat
  module Model::Notice::ProgramNotice
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
    def do_send
      r = app.api.post 'message/subscribe/send', **message_hash, base: BASE
      if r['errcode'] == 0
        self.update msg_id: r['msgid']
        msg_request.update sent_at: Time.current if msg_request
      else
        r
      end
    end

    def message_hash
      {
        template_id: template.template_id,
        touser: wechat_user.uid,
        data: data
      }
    end

  end
end
