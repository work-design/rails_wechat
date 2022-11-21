module Wechat::Api
  module Suite::Service
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/service/'

    def token
      r = client.with(origin: BASE).post 'get_suite_token', json: { suite_id: app.suite_id, suite_secret: app.secret, suite_ticket: app.suite_ticket }
      return r if r.status != 200
      r.json
    end

    def pre_auth_code
      get 'get_pre_auth_code', origin: BASE
    end

    def permanent_code(auth_code)
      post 'get_permanent_code', auth_code: auth_code, origin: BASE
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
        origin: BASE
      )
    end

    def auth_user(code)
      get 'getuserinfo3rd', params: { code: code }, origin: BASE
    end

    def login_info(auth_code)
      post 'get_login_info', auth_code: auth_code, origin: BASE
    end

    def auth_info(auth_corpid, permanent_code)
      post 'get_auth_info', auth_corpid: auth_corpid, permanent_code:permanent_code, origin: BASE
    end

    def corp_token(auth_corpid, permanent_code)
      post 'get_corp_token', auth_corpid: auth_corpid, permanent_code:permanent_code, origin: BASE
    end

    # https://developer.work.weixin.qq.com/document/path/91122
    def user_detail(user_ticket)
      post 'getuserdetail3rd', user_ticket: user_ticket, origin: BASE
    end

    def external_userid(unionid:, openid:, **options)
      post 'externalcontact/unionid_to_external_userid_3rd', unionid: unionid, openid: openid, origin: BASE, **options
    end

  end
end

