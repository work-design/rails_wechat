class Wechat::WorkApi
  module Contact
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/'

    def add_contact_way(type: 1, scene: 2, **options)
      post 'add_contact_way', origin: BASE, type: type, scene: scene, **options
    end

    def list_contact_way(**options)
      post 'list_contact_way', origin: BASE, **options
    end

    def get_contact_way(config_id, **options)
      post 'get_contact_way', origin: BASE, config_id: config_id, **options
    end

    def get_follow_user_list
      get 'get_follow_user_list', origin: BASE
    end

    def del_contact_way(config_id, **options)
      post 'del_contact_way', origin: BASE, config_id: config_id, **options
    end

    def update_contact_way(config_id, **options)
      post 'update_contact_way', origin: BASE, config_id: config_id, **options
    end

    def list(userid)
      r = get 'list', origin: BASE, userid: userid
      r['external_userid']
    end

    def item(external_userid, **options)
      get 'get', origin: BASE, external_userid: external_userid, **options
    end

    def batch(userid, **options)
      post 'batch/get_by_user', origin: BASE, userid_list: [userid], **options
    end

    def remark(userid, external_userid, **options)
      post 'remark', origin: BASE, userid: userid, external_userid: external_userid, **options
    end

    def new_external_userid(*external_userid, **options)
      post 'get_new_external_userid', origin: BASE, external_userid_list: external_userid, **options
    end

    def service_external_userid(external_userid, **options)
      post 'to_service_external_userid', origin: BASE, external_userid: external_userid, **options
    end

  end
end

