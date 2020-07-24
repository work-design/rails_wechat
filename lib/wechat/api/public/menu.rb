module Wechat::Api::Public::Menu
  BASE = 'https://api.weixin.qq.com/cgi-bin/'

  def menu
    get 'menu/get'
  end

  def menu_delete
    get 'menu/delete'
  end

  def menu_create(menu)
    # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
    post 'menu/create', menu
  end

  def menu_addconditional(menu)
    # Wechat not accept 7bit escaped json(eg \uxxxx), must using UTF-8, possible security vulnerability?
    post 'menu/addconditional', menu
  end

  def menu_trymatch(user_id)
    post 'menu/trymatch', user_id: user_id
  end

  def menu_delconditional(menuid)
    post 'menu/delconditional', menuid: menuid
  end

  def templates
    r = get 'template/get_all_private_template'
    r['template_list']
  end

  def add_template(template_id_short)
    post 'template/api_add_template', template_id_short: template_id_short
  end

  def del_template(template_id)
    post 'template/del_private_template', template_id: template_id
  end


end
