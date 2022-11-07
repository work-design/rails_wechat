module Wechat::Api
  module Suite::IdConvert
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/idconvert/'


    def to_pending_id(external_userid)
      raw_post 'external_userid_to_pending_id', external_userid: external_userid, base: BASE
    end
  end
end

