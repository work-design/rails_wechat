module Wechat::Api
  module Work::IdConvert
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/idconvert/'

    def pending_id(*external_userid, **options)
      post 'batch/external_userid_to_pending_id', external_userid: external_userid, origin: BASE, **options
    end

    def external_userid(unionid:, openid:, subject_type: 1, **options)
      post 'unionid_to_external_userid', unionid: unionid, openid: openid, subject_type: subject_type, origin: BASE, **options
    end

  end
end
