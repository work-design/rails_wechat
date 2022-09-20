module Wechat
  class CorpsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_corp, only: [:notify, :login, :verify]

    # 指令回调URL: /wechat/corps/:id/notify
    def notify
      @corp_ticket = @corp.corp_tickets.build
      r = Hash.from_xml(request.raw_post)['xml']
      logger.debug "\e[35m  body is: #{r}  \e[0m"

      @corp_ticket.suiteid = r['ToUserName']
      @corp_ticket.ticket_data = r['Encrypt']
      @corp_ticket.agent_id = r['AgentID']

      if @corp_ticket.save
        render plain: 'success'
      else
        head :no_content
      end
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

    def login
      @corp_user = @corp.generate_corp_user(params[:code])
      @corp_user.save

      xxx(@corp_user)
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
