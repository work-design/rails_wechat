module Wechat::Api::Work::User
  BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

  def getuserinfo(code)
    get 'user/getuserinfo', params: { code: code }
  end

  def convert_to_openid(userid)
    post 'user/convert_to_openid', userid: userid, agentid: @agentid
  end

  def invite_user(userid)
    post 'invite/send', userid: userid
  end

  def user_auth_success(userid)
    get 'user/authsucc', params: { userid: userid }
  end

  ## 成员管理
  # 创建成员
  def user_create(user)
    post 'user/create', user
  end

  # 读取成员
  def user(userid)
    get 'user/get', params: { userid: userid }
  end

  # 更新成员
  def user_update(user)
    post 'user/update', user
  end

  # 删除成员
  def user_delete(userid)
    get 'user/delete', params: { userid: userid }
  end

  # 批量删除成员
  def user_batchdelete(useridlist)
    post 'user/batchdelete', useridlist: useridlist
  end

  def batch_job_result(jobid)
    get 'batch/getresult', params: { jobid: jobid }
  end

  def batch_replaceparty(media_id)
    post 'batch/replaceparty', media_id: media_id
  end

  def batch_syncuser(media_id)
    post 'batch/syncuser', media_id: media_id
  end

  def batch_replaceuser(media_id)
    post 'batch/replaceuser', media_id: media_id
  end

  def department_create(name, parentid)
    post 'department/create', name: name, parentid: parentid
  end

  def department_delete(departmentid)
    get 'department/delete', params: { id: departmentid }
  end

  def department_update(departmentid, name = nil, parentid = nil, order = nil)
    post 'department/update', { id: departmentid, name: name, parentid: parentid, order: order }.reject { |_k, v| v.nil? }
  end

  def department(departmentid = 1)
    get 'department/list', params: { id: departmentid }
  end

  def user_simplelist(department_id, fetch_child = 0, status = 0)
    get 'user/simplelist', params: { department_id: department_id, fetch_child: fetch_child, status: status }
  end

  def user_list(department_id, fetch_child = 0, status = 0)
    get 'user/list', params: { department_id: department_id, fetch_child: fetch_child, status: status }
  end

  def tag_create(tagname, tagid = nil)
    post 'tag/create', tagname: tagname, tagid: tagid
  end

  def tag_update(tagid, tagname)
    post 'tag/update', tagid: tagid, tagname: tagname
  end

  def tag_delete(tagid)
    get 'tag/delete', params: { tagid: tagid }
  end

  def tags
    get 'tag/list'
  end

  def tag(tagid)
    get 'tag/get', params: { tagid: tagid }
  end

  def tag_add_user(tagid, userids = nil, departmentids = nil)
    post 'tag/addtagusers', tagid: tagid, userlist: userids, partylist: departmentids
  end

  def tag_del_user(tagid, userids = nil, departmentids = nil)
    post 'tag/deltagusers', tagid: tagid, userlist: userids, partylist: departmentids
  end

end
