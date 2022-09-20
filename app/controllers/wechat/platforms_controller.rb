module Wechat
  class PlatformsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_platform, only: [:show, :message, :callback]

    def show
    end

    # 授权事件接收URL: platforms/:id/notify
    def notify
      @ticket = @platform.platform_tickets.build(ticket_params)
      r = Hash.from_xml(request.raw_post)['xml']
      @ticket.appid = r['AppId']
      @ticket.ticket_data = r['Encrypt']

      if @ticket.save
        render plain: 'success'
      else
        head :no_content
      end
    end

    def callback
      @auth = @platform.auths.build
      @auth.auth_code = params[:auth_code]
      @auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
      @auth.save
    end

    # 消息与事件接收URL: platforms/:id/callback/$APPID$
    def message
      @receive = @platform.receives.build
      @receive.appid = params[:appid]
      r = Hash.from_xml(request.body.read)['xml']
      @receive.encrypt_data = r['Encrypt']
      @receive.save

      render plain: @receive.request.to_wechat
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

    def set_app
      @app = @platform.agencies.find_by(appid: params[:appid]).app
    end

  end
end
