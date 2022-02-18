module Wechat::Api
  module Provider::Service
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/service/'

    def token
      client.post 'get_provider_token', { corpid: app.corp_id, provider_secret: app.provider_secret }.to_json, base: BASE
    end

    def login_info(auth_code)
      post 'get_login_info', auth_code: auth_code, base: BASE
    end

  end
end

