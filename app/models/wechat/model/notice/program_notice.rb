module Wechat
  module Model::Notice::ProgramNotice
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
    def do_send
      app.api.post 'message/subscribe/send', **message_hash, base: BASE
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
