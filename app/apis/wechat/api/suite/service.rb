module Wechat::Api
  module Suite::Service
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/service/'

    def token
      client.post 'get_suite_token', suite_id: app.suite_id, suite_secret: app.secret, suite_ticket: app.suite_ticket, base: BASE
    end

  end
end

