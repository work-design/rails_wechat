module Wechat
  class CorpsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_corp, only: [:login, :notify]

    def login
      @corp_user = @corp.generate_corp_user(params[:code])
      @corp_user.save

      login_by_corp_user(@corp_user)
    end

    # 指令回调URL: /wechat/corps/:id/notify
    def notify
      @suite_ticket = @corp.suite_tickets.build
      r = Hash.from_xml(request.raw_post)['xml']
      logger.debug "\e[35m  body is: #{r}  \e[0m"

      @suite_ticket.to = r['ToUserName']
      @suite_ticket.ticket_data = r['Encrypt']
      @suite_ticket.agent_id = r['AgentID']

      if @suite_ticket.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    private
    def set_corp
      @corp = Corp.find(params[:id])
    end

  end
end
