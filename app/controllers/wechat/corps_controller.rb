module Wechat
  class CorpsController < BaseController
    before_action :set_corp, only: [:show, :verify]

    def show
      render plain: 'success'
    end

    # 消息与事件接收URL: /wechat/corps/:id/callback
    def callback
      r = Hash.from_xml(request.raw_post)['xml']
      @suite_receive = SuiteReceive.new
      @suite_receive.corp_id = r['ToUserName']
      @suite_receive.user_id = r['FromUserName']
      @suite_receive.agent_id = r['AgentID']
      @suite_receive.msg_type = r['MsgType']
      @suite_receive.msg_id = r['MsgId']
      @suite_receive.content = r['Content']
      @suite_receive.event = r['Event']
      @suite_receive.event_key = r['EventKey']
      @suite_receive.encrypt_data = r['Encrypt']

      if @suite_receive.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    # get /notify
    # get /callback
    def verify
      r = @corp.decrypt(params[:echostr])

      render plain: r
    end


    private
    def set_corp
      @corp = Corp.find(params[:id])
    end

  end
end
