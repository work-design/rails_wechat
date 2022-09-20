module Wechat::Api
  module Work::User
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def getuserinfo(code)
      get 'user/getuserinfo', params: { code: code }, base: BASE
    end

    def auth_user(code)
      get 'auth/getuserinfo', params: { code: code }, base: BASE
    end

    def convert_to_openid(userid)
      post 'user/convert_to_openid', userid: userid, agentid: @agentid, base: BASE
    end

    def user_detail(user_ticket)
      post 'user/getuserdetail', user_ticket: user_ticket, base: BASE
    end

    def invite_user(userid)
      post 'invite/send', userid: userid, base: BASE
    end

    def user_auth_success(userid)
      get 'user/authsucc', params: { userid: userid }, base: BASE
    end

    ## 成员管理
    # 创建成员
    def user_create(user)
      post 'user/create', user
    end

    # 读取成员
    def user(userid)
      get 'user/get', params: { userid: userid }, base: BASE
    end

    # 更新成员
    def user_update(user)
      post 'user/update', user
    end

    # 删除成员
    def user_delete(userid)
      get 'user/delete', params: { userid: userid }, base: BASE
    end

    # 批量删除成员
    def user_batchdelete(useridlist)
      post 'user/batchdelete', useridlist: useridlist, base: BASE
    end

    def batch_job_result(jobid)
      get 'batch/getresult', params: { jobid: jobid }, base: BASE
    end

    def batch_replaceparty(media_id)
      post 'batch/replaceparty', media_id: media_id, base: BASE
    end

    def batch_syncuser(media_id)
      post 'batch/syncuser', media_id: media_id, base: BASE
    end

    def batch_replaceuser(media_id)
      post 'batch/replaceuser', media_id: media_id, base: BASE
    end

    def department_create(name, parentid)
      post 'department/create', name: name, parentid: parentid, base: BASE
    end

    def department_delete(departmentid)
      get 'department/delete', params: { id: departmentid }, base: BASE
    end

    def department_update(departmentid, name = nil, parentid = nil, order = nil)
      post 'department/update', { id: departmentid, name: name, parentid: parentid, order: order }.reject { |_k, v| v.nil? }
    end

    def department(id = nil)
      if id.present?
        get 'department/list', params: { id: id }, base: BASE
      else
        get 'department/list', base: BASE
      end
    end

    def user_simplelist(department_id, fetch_child = 0, status = 0)
      get 'user/simplelist', params: { department_id: department_id, fetch_child: fetch_child, status: status }, base: BASE
    end

    def user_list(department_id, fetch_child = 0, status = 0)
      get 'user/list', params: { department_id: department_id, fetch_child: fetch_child, status: status }, base: BASE
    end

    def tag_create(tagname, tagid = nil)
      post 'tag/create', tagname: tagname, tagid: tagid, base: BASE
    end

    def tag_update(tagid, tagname)
      post 'tag/update', tagid: tagid, tagname: tagname, base: BASE
    end

    def tag_delete(tagid)
      get 'tag/delete', params: { tagid: tagid }, base: BASE
    end

    def tags
      get 'tag/list', base: BASE
    end

    def tag(tagid)
      get 'tag/get', params: { tagid: tagid }, base: BASE
    end

    def tag_add_user(tagid, userids = nil, departmentids = nil)
      post 'tag/addtagusers', tagid: tagid, userlist: userids, partylist: departmentids, base: BASE
    end

    def tag_del_user(tagid, userids = nil, departmentids = nil)
      post 'tag/deltagusers', tagid: tagid, userlist: userids, partylist: departmentids, base: BASE
    end

  end
end
