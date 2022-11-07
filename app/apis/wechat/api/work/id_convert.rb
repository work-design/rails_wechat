module Wechat::Api
  module Work::IdConvert
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/idconvert/'

    def to_pending_id(*external_userid, **options)
      post 'batch/external_userid_to_pending_id', external_userid: external_userid, base: BASE, **options
    end
  end
end

