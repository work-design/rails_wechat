class Wechat::ProviderApi
  module Service
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/service/'

    def token
      r = client.with(origin: BASE).post 'get_provider_token', json: { corpid: app.corp_id, provider_secret: app.provider_secret }
      r.json
    end

    def login_info(auth_code)
      post 'get_login_info', auth_code: auth_code, origin: BASE
    end

    def open_corpid(corpid)
      provider_post 'corpid_to_opencorpid', corpid: corpid, origin: BASE
    end

  end
end

