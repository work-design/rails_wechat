module Wechat::Api::Work::Agent
  BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

  def gettoken
    get 'gettoken', params: { corpid: app.appid, corpsecret: app.secret }
  end

  def agent_list
    get 'agent/list', base: BASE
  end

  def agent(agentid)
    get 'agent/get', params: { agentid: agentid }, base: BASE
  end

  def checkin(useridlist, starttime = Time.now.beginning_of_day, endtime = Time.now.end_of_day, opencheckindatatype = 3)
    post 'checkin/getcheckindata', opencheckindatatype: opencheckindatatype, starttime: starttime.to_i, endtime: endtime.to_i, useridlist: useridlist, base: BASE
  end

end
