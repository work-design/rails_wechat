# frozen_string_literal: true

class Wechat::Api::Work < Wechat::Api::Base
  require 'wechat/api/work/agent'
  include Wechat::Api::Work::Agent
  API_BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

  def initialize(app)
    @client = Wechat::HttpClient.new(API_BASE)
    @access_token = Wechat::AccessToken::Work.new(@client, app)
    @agentid = app.agentid
    @jsapi_ticket = Wechat::JsapiTicket::Work.new(@client, app, @access_token)
  end

  def agent_list
    get 'agent/list'
  end

  def agent(agentid)
    get 'agent/get', params: { agentid: agentid }
  end

  def checkin(useridlist, starttime = Time.now.beginning_of_day, endtime = Time.now.end_of_day, opencheckindatatype = 3)
    post 'checkin/getcheckindata', opencheckindatatype: opencheckindatatype, starttime: starttime.to_i, endtime: endtime.to_i, useridlist: useridlist
  end

  def user(userid)
    get 'user/get', params: { userid: userid }
  end

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

  def user_create(user)
    post 'user/create', user
  end

  def user_delete(userid)
    get 'user/delete', params: { userid: userid }
  end

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
