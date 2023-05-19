module Wechat::Api
  module Work::Agent
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def token
      r = client.with(origin: BASE).get 'gettoken', params: { corpid: app.corpid, corpsecret: app.secret }
      r.json
    end

    def jsapi_ticket
      get 'get_jsapi_ticket', origin: BASE
    end

    def agent_list
      get 'agent/list', origin: BASE
    end

    def agent_ticket(**options)
      get 'ticket/get', params: { type: 'agent_config' }, origin: BASE, **options
    end

    def agent(agentid)
      get 'agent/get', params: { agentid: agentid }, origin: BASE
    end

    def checkin(useridlist, starttime = Time.current.beginning_of_day, endtime = Time.current.end_of_day, opencheckindatatype = 3)
      post 'checkin/getcheckindata', opencheckindatatype: opencheckindatatype, starttime: starttime.to_i, endtime: endtime.to_i, useridlist: useridlist, origin: BASE
    end

  end
end
