module Wechat::Api
  module Provider::License
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/license/'

    def active_info_by_code(corpid, active_code)
      provider_get 'get_active_info_by_code', params: { corpid: corpid, active_code: active_code }, origin: BASE
    end

    def list_actived_account(corpid)
      provider_get 'list_actived_account', params: { corpid: corpid }, origin: BASE
    end

  end
end
