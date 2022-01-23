module Wechat
  class ProvidersController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_provider, only: [:verify, :notify, :callback, :login]
    before_action :verify_signature, only: [:verify]

    # 指令回调URL: /wechat/providers/notify
    def notify
      @provider_ticket = ProviderTicket.new(ticket_params)
      r = Hash.from_xml(request.raw_post)['xml']
      @provider_ticket.suite_id = r['ToUserName']
      @provider_ticket.ticket_data = r['Encrypt']
      @provider_ticket.agent_id = r['AgentID']

      if @provider_ticket.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    # 消息与事件接收URL: /wechat/providers/:id/callback
    def callback
      r = Hash.from_xml(request.raw_post)['xml']
      @provider_receive = @provider.provider_receives.build
      @provider_receive.corp_id = r['ToUserName']
      @provider_receive.user_id = r['FromUserName']
      @provider_receive.agent_id = r['AgentID']
      @provider_receive.msg_type = r['MsgType']
      @provider_receive.msg_id = r['MsgId']
      @provider_receive.content = r['Content']
      @provider_receive.event = r['Event']
      @provider_receive.event_key = r['EventKey']
      @provider_receive.encrypt_data = r['Encrypt']

      if @provider_receive.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    # get /notify
    # get /callback
    def verify
      r = @provider.decrypt(params[:echostr])

      render plain: r
    end

    def login
      @corp_user = @provider.generate_corp_user(params[:code])
      @corp_user.save

      if @corp_user
        render :login, locals: { url: url }
      else
        render :login, locals: { url: url }
      end
    end

    private
    def ticket_params
      params.permit(
        :timestamp,
        :nonce,
        :msg_signature
      )
    end

    def set_provider
      @provider = Provider.find(params[:id])
    end

    def set_app
      @app = @platform.agencies.find_by(appid: params[:appid]).app
    end

    def verify_signature
      if @provider
        # 消息体签名校验: https://open.work.weixin.qq.com/api/doc/90000/90139/90968#消息体签名校验
        dev_signature = Wechat::Signature.hexdigest(@provider.token, params[:timestamp], params[:nonce], params[:echostr])
        forbidden = (params[:msg_signature] != dev_signature)
      else
        forbidden = true
      end

      render plain: 'Forbidden', status: 403 if forbidden
    end

  end
end
