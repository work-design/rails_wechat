module Wechat::Api
  module Public::Menu
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    def menu
      get 'menu/get', origin: BASE
    end

    def menu_delete
      get 'menu/delete', origin: BASE
    end

    def menu_create(menu)
      post 'menu/create', **menu, origin: BASE
    end

    def menu_addconditional(menu)
      post 'menu/addconditional', **menu, origin: BASE
    end

    def menu_trymatch(user_id)
      post 'menu/trymatch', user_id: user_id, origin: BASE
    end

    def menu_delconditional(menuid)
      post 'menu/delconditional', menuid: menuid, origin: BASE
    end

    def templates
      r = get 'template/get_all_private_template', origin: BASE
      r['template_list']
    end

    def add_template(template_id_short)
      post 'template/api_add_template', template_id_short: template_id_short, origin: BASE
    end

    def del_template(template_id)
      post 'template/del_private_template', template_id: template_id, origin: BASE
    end

  end
end
