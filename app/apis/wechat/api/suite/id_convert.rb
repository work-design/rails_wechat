module Wechat::Api
  module Suite::IdConvert
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/idconvert/'


    def to_pending_id(*external_userid, **options)
      raw_post 'batch/external_userid_to_pending_id', external_userid: external_userid, base: BASE, **options
    end
  end
end

