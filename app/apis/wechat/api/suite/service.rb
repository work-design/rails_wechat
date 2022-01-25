module Wechat::Api
  module Suite::Service
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/service/'

    def token
      client.post 'get_suite_token', { suite_id: app.suite_id, suite_secret: app.secret, suite_ticket: app.suite_ticket }.to_json, base: BASE
    end

    def pre_auth_code
      get 'get_pre_auth_code', base: BASE
    end

    def permanent_code(auth_code)
      r = post 'get_permanent_code', auth_code: auth_code, base: BASE
    end

    # auth_type 1, 测试授权
    def set_session_info(pre_auth_code, auth_type: 1, appid: [])
      post(
        'set_session_info',
        pre_auth_code: pre_auth_code,
        session_info: {
          appid: appid,
          auth_type: auth_type
        },
        base: BASE
      )
    end

    def auth_info(auth_corpid, permanent_code)
      post 'get_auth_info', auth_corpid: auth_corpid, permanent_code:permanent_code, base: BASE
    end

    def corp_token(auth_corpid, permanent_code)
      post 'get_corp_token', auth_corpid: auth_corpid, permanent_code:permanent_code, base: BASE
    end

    # https://developer.work.weixin.qq.com/document/path/91122
    def user_detail(user_ticket)
      post 'getuserdetail3rd', user_ticket: user_ticket, base: BASE
    end

  end
end

