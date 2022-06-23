module Wechat::Api
  module Work::Agent
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def token
      client.get 'gettoken', params: { corpid: app.appid, corpsecret: app.secret }, base: BASE
    end

    def jsapi_ticket
      get 'get_jsapi_ticket', base: BASE
    end

    def agent_list
      get 'agent/list', base: BASE
    end

    def agent_ticket
      get 'ticket/get', params: { type: 'agent_config' }, base: BASE
    end

    def agent(agentid)
      get 'agent/get', params: { agentid: agentid }, base: BASE
    end

    def checkin(useridlist, starttime = Time.current.beginning_of_day, endtime = Time.current.end_of_day, opencheckindatatype = 3)
      post 'checkin/getcheckindata', opencheckindatatype: opencheckindatatype, starttime: starttime.to_i, endtime: endtime.to_i, useridlist: useridlist, base: BASE
    end

  end
end
