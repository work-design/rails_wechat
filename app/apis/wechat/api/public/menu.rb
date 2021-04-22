module Wechat::Api::Public::Menu
  BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def menu
    get 'menu/get', base: BASE
  end

  def menu_delete
    get 'menu/delete', base: BASE
  end

  def menu_create(menu)
    post 'menu/create', **menu, base: BASE
  end

  def menu_addconditional(menu)
    post 'menu/addconditional', **menu, base: BASE
  end

  def menu_trymatch(user_id)
    post 'menu/trymatch', user_id: user_id, base: BASE
  end

  def menu_delconditional(menuid)
    post 'menu/delconditional', menuid: menuid, base: BASE
  end

  def templates
    r = get 'template/get_all_private_template', base: BASE
    r['template_list']
  end

  def add_template(template_id_short, _ = nil)
    post 'template/api_add_template', template_id_short: template_id_short, base: BASE
  end

  def del_template(template_id)
    post 'template/del_private_template', template_id: template_id, base: BASE
  end

end
