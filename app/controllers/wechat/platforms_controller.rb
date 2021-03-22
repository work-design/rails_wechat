module Wechat
  class PlatformsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false
    before_action :set_platform, only: [:show, :message, :callback]

    # 授权事件接收URL: platforms/notice
    def notice
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
      @wechat_auth = @platform.wechat_auths.build
      @wechat_auth.auth_code = params[:auth_code]
      @wechat_auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
      @wechat_auth.save
    end

    # 消息与事件接收URL: platforms/:id/callback/$APPID$
    def message
      @receive = @platform.receives.build
      @receive.appid = params[:appid]
      r = Hash.from_xml(request.body.read)['xml']
      @receive.encrypt_data = r['Encrypt']
      @receive.save

      request = @receive.reply
      render plain: request.to_wechat
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

    def set_platform
      @platform = Platform.find(params[:id])
    end

    def set_wechat_app
      @app = @platform.agencies.find_by(appid: params[:appid]).app
    end

  end
end
