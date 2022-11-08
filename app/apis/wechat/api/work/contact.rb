module Wechat::Api
  module Work::Contact
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/'

    def add_contact_way(type: 1, scene: 2, **options)
      post(
        'add_contact_way',
        type: type,
        scene: scene,
        **options,
        origin: BASE
      )
    end

    def list_contact_way(**options)
      post 'list_contact_way', origin: BASE, **options
    end

    def get_contact_way(config_id, **options)
      post 'get_contact_way', config_id: config_id, origin: BASE, **options
    end

    def get_follow_user_list
      get 'get_follow_user_list', origin: BASE
    end

    def del_contact_way(config_id, **options)
      post 'del_contact_way', config_id: config_id, origin: BASE, **options
    end

    def update_contact_way(config_id, **options)
      post 'update_contact_way', config_id: config_id, origin: BASE, **options
    end

    def list(userid)
      r = get 'list', params: { userid: userid }, origin: BASE
      r['external_userid']
    end

    def item(external_userid, **options)
      get 'get', params: { external_userid: external_userid, **options }, origin: BASE
    end

    def batch(userid, **options)
      post 'batch/get_by_user', userid_list: [userid], origin: BASE, **options
    end

    def remark(userid, external_userid, **options)
      post 'remark', userid: userid, external_userid: external_userid, origin: BASE, **options
    end

    def new_external_userid(*external_userid, **options)
      post 'get_new_external_userid', external_userid_list: external_userid, origin: BASE, **options
    end

  end
end

