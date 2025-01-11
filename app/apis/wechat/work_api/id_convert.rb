class Wechat::WorkApi
  module IdConvert
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/idconvert/'

    def pending_id(*external_userid, **options)
      post 'batch/external_userid_to_pending_id', external_userid: external_userid, origin: BASE, **options
    end

    def external_userid(unionid:, openid:, **options)
      post 'unionid_to_external_userid', unionid: unionid, openid: openid, origin: BASE, **options
    end

  end
end
