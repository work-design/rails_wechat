module Wechat
  module Model::Notice::PublicNotice
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def do_send
      r = app.api.post 'message/template/send', **message_hash, origin: BASE
      if r['errcode'] == 0
        self.msg_id = r['msgid']
        self.status = 'sent'
      end
      self.result = r
      self.save
      r
    end

    def message_hash
      {
        touser: open_id,
        template_id: template.template_id,
        url: link,
        data: data
      }
    end

  end
end
