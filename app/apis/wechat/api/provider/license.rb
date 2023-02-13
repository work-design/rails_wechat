module Wechat::Api
  module Provider::License
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/license/'

    def active_info_by_code(corpid, active_code)
      provider_post 'get_active_info_by_code', corpid: corpid, active_code: active_code, origin: BASE
    end

    def list_actived_account(corpid, **options)
      provider_post 'list_actived_account', corpid: corpid, origin: BASE, **options
    end

    def active_info(corpid, userid, **options)
      provider_post 'get_active_info_by_user', corpid: corpid, userid: userid, origin: BASE, **options
    end

    def list_order(corpid)
      provider_post 'list_order', corpid: corpid, origin: BASE, **options
    end

    def list_order_account(order_id)
      provider_post 'list_order_account', order_id: order_id, origin: BASE, **options
    end

  end
end
