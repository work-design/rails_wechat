class Wechat::WorkApi
  module User
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def auth_user(code)
      get 'auth/getuserinfo', origin: BASE, code: code
    end

    def convert_to_openid(userid)
      post 'user/convert_to_openid', userid: userid, agentid: @agentid, origin: BASE
    end

    def user_detail(user_ticket)
      post 'user/getuserdetail', user_ticket: user_ticket, origin: BASE
    end

    def invite_user(userid)
      post 'invite/send', userid: userid, origin: BASE
    end

    def user_auth_success(userid)
      get 'user/authsucc', origin: BASE, userid: userid
    end

    ## 成员管理
    # 创建成员
    def user_create(user)
      post 'user/create', user
    end

    # 读取成员
    def user(userid)
      get 'user/get', origin: BASE, userid: userid
    end

    # 更新成员
    def user_update(user)
      post 'user/update', user
    end

    # 删除成员
    def user_delete(userid)
      get 'user/delete', origin: BASE, userid: userid
    end

    # 批量删除成员
    def user_batchdelete(useridlist)
      post 'user/batchdelete', useridlist: useridlist, origin: BASE
    end

    def batch_job_result(jobid)
      get 'batch/getresult', origin: BASE, jobid: jobid
    end

    def batch_replaceparty(media_id)
      post 'batch/replaceparty', origin: BASE, media_id: media_id
    end

    def batch_syncuser(media_id)
      post 'batch/syncuser', origin: BASE, media_id: media_id
    end

    def batch_replaceuser(media_id)
      post 'batch/replaceuser', media_id: media_id, origin: BASE
    end

    def department_create(name, parentid)
      post 'department/create', name: name, parentid: parentid, origin: BASE
    end

    def department_delete(departmentid)
      get 'department/delete', origin: BASE, id: departmentid
    end

    def department_update(departmentid, name = nil, parentid = nil, order = nil)
      post 'department/update', { id: departmentid, name: name, parentid: parentid, order: order }.reject { |_k, v| v.nil? }
    end

    def department(id = nil)
      if id.present?
        get 'department/list', origin: BASE, id: id
      else
        get 'department/list', origin: BASE
      end
    end

    def user_simplelist(department_id, fetch_child = 0, status = 0)
      get 'user/simplelist', origin: BASE, department_id: department_id, fetch_child: fetch_child, status: status
    end

    def user_list(department_id, fetch_child = 0, status = 0)
      get 'user/list', origin: BASE, department_id: department_id, fetch_child: fetch_child, status: status
    end

    def tag_create(tagname, tagid = nil)
      post 'tag/create', tagname: tagname, tagid: tagid, origin: BASE
    end

    def tag_update(tagid, tagname)
      post 'tag/update', tagid: tagid, tagname: tagname, origin: BASE
    end

    def tag_delete(tagid)
      get 'tag/delete', origin: BASE, tagid: tagid
    end

    def tags
      get 'tag/list', origin: BASE
    end

    def tag(tagid)
      get 'tag/get', origin: BASE, tagid: tagid
    end

    def tag_add_user(tagid, userids = nil, departmentids = nil)
      post 'tag/addtagusers', tagid: tagid, userlist: userids, partylist: departmentids, origin: BASE
    end

    def tag_del_user(tagid, userids = nil, departmentids = nil)
      post 'tag/deltagusers', tagid: tagid, userlist: userids, partylist: departmentids, origin: BASE
    end

  end
end
