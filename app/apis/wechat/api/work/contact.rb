module Wechat::Api
  module Work::Contact
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/'

    def add_contact_way(type: 1, scene: 2, **options)
      post(
        'add_contact_way',
        type: type,
        scene: scene,
        **options,
        base: BASE
      )
    end

    def list_contact_way(**options)
      post 'list_contact_way', base: BASE, **options
    end

    def get_follow_user_list
      get 'get_follow_user_list', base: BASE
    end

  end
end

