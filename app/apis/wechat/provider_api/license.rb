class Wechat::ProviderApi
  module License
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/license/'

    def active_info_by_code(corpid, active_code, **options)
      provider_post 'get_active_info_by_code', corpid: corpid, active_code: active_code, origin: BASE, **options
    end

    def list_actived_account(corpid, **options)
      provider_post 'list_actived_account', corpid: corpid, origin: BASE, **options
    end

    def active_info(corpid, userid, **options)
      provider_post 'get_active_info_by_user', corpid: corpid, userid: userid, origin: BASE, **options
    end

    def active_account(corpid, userid, active_code, **options)
      provider_post(
        'active_account',
        corpid: corpid,
        userid: userid,
        active_code: active_code,
        origin: BASE,
        **options
      )
    end

    def list_order(corpid, **options)
      provider_post 'list_order', corpid: corpid, origin: BASE, **options
    end

    def list_order_account(order_id, **options)
      provider_post 'list_order_account', order_id: order_id, origin: BASE, **options
    end

  end
end
