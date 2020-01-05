# frozen_string_literal: true

class Wechat::Api::Public < Wechat::Api::Base

  # https://developers.weixin.qq.com/doc/offiaccount/User_Management/User_Tag_Management.html
  def tags
    get 'tags/get'
  end

  def tag_create(tag_name, tag_id = nil)
    if tag_id.present?
      r = post 'tags/update', { tag: { id: tag_id, name: tag_name } }
    else
      r = post 'tags/create', { tag: { name: tag_name } }
    end

    if r['errcode'] == 0
      { 'tag' => { 'id' => tag_id, 'name' => tag_name } }
    elsif r['errcode'] == 45157
      { 'tag' => tags['tags'].find { |i| i['name'] == tag_name } }
    else
      r
    end
  end

  def tag_delete(tagid)
    post 'tags/delete', tag: { id: tagid }
  end

  def tag_add_user(tagid, *openids)
    post 'tags/members/batchtagging', openid_list: openids, tagid: tagid
  end

  def tag_del_user(tagid, *openids)
    post 'tags/members/batchuntagging', openid_list: openids, tagid: tagid
  end

  def tag(tagid, next_openid = '')
    post 'user/tag/get', tagid: tagid, next_openid: next_openid
  end

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
