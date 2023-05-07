module Wechat
  class AgentsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_agent, only: [:show, :login]
    before_action :verify_signature, only: [:show, :create]

    def show
      echostr = @agent.decrypt(params[:echostr])
      render plain: echostr
    end

    def create
      @receive = @agent.receives.build

      if params['ToUserName']
        r = params.permit('Encrypt')
        @receive.msg_format = 'json'
      else
        r = Hash.from_xml(request.raw_post).fetch('xml', {})
      end

      if r['Encrypt']
        @receive.encrypt_data = r['Encrypt']
      else
        @receive.message_hash = r
      end
      @receive.save

      render plain: @receive.request.to_wechat
    end

    def login
      @corp_user = @agent.generate_corp_user(params[:code])
      @corp_user.save

      login_by_corp_user(@corp_user)
    end

    private
    def set_agent
      @agent = Agent.find(params[:id])
    end

    def verify_signature
      if ['POST'].include?(request.request_method)
        r = Hash.from_xml(request.raw_post).fetch('xml', {})
        msg_encrypt = r['Encrypt']
      else
        msg_encrypt = params[:echostr]
      end
      forbidden = (params[:msg_signature] != Wechat::Signature.hexdigest(@agent.token, params[:timestamp], params[:nonce], msg_encrypt))

      render plain: 'Forbidden', status: 403 if forbidden
    end

  end
end
