module Wechat::Api
  module Suite::Contact
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

    def list_contact_way
      post 'list_contact_way'
    end

  end
end

