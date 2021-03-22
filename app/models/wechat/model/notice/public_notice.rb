module Wechat
  module Model::Notice::PublicNotice
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def do_send
      r = app.api.post 'message/template/send', **message_hash, base: BASE
      if r['errcode'] == 0
        self.update msg_id: r['msgid']
        subscribe.update sending_at: Time.now if subscribe
      else
        r
      end
    end

    def message_hash
      {
        touser: wechat_user.uid,
        template_id: template.template_id,
        url: link,
        data: data
      }
    end

  end
end
