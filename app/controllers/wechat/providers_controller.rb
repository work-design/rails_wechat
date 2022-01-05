module Wechat
  class ProvidersController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_provider, only: [:show, :message, :callback]
    before_action :verify_signature, only: [:message]

    # 授权事件接收URL: platforms/notice
    def notify
      @ticket = Ticket.new(ticket_params)
      r = Hash.from_xml(request.raw_post)['xml']
      @ticket.appid = r['AppId']
      @ticket.ticket_data = r['Encrypt']

      if @ticket.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    def show
    end

    def callback
      @auth = @platform.auths.build
      @auth.auth_code = params[:auth_code]
      @auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
      @auth.save
    end

    # 消息与事件接收URL: /wechat/providers/callback/$CORPID$
    def message
      r = @provider.decrypt(params[:echostr])
      # @receive = @platform.receives.build
      # @receive.appid = params[:appid]
      # r = Hash.from_xml(request.body.read)['xml']
      # @receive.encrypt_data = r['Encrypt']
      # @receive.save

      render plain: r
    end

    private
    def ticket_params
      params.permit(
        :signature,
        :timestamp,
        :nonce,
        :msg_signature
      )
    end

    def set_provider
      @provider = Provider.find_by(corp_id: params[:corp_id])
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
