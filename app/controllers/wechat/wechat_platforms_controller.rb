class Wechat::WechatPlatformsController < Wechat::BaseController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_wechat_platform, only: [:show, :message, :callback]

  def notice
    @wechat_ticket = WechatTicket.new(ticket_params)
    r = Hash.from_xml(request.raw_post)['xml']
    @wechat_ticket.appid = r['AppId']
    @wechat_ticket.ticket_data = r['Encrypt']

    if @wechat_ticket.save
      render plain: 'success'
    else
      head :no_content
    end
  end

  def show
  end

  # 授权事件接收
  def callback
    @wechat_auth = @wechat_platform.wechat_auths.build
    @wechat_auth.auth_code = params[:auth_code]
    @wechat_auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
    @wechat_auth.save
  end

  def message
    @wechat_received = @wechat_platform.wechat_receiveds.build
    @wechat_received.appid = params[:appid]
    r = Hash.from_xml(request.body.read)['xml']
    @wechat_received.encrypt_data = r['Encrypt']
    @wechat_received.save

    request = @wechat_received.reply
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

  def set_wechat_platform
    @wechat_platform = WechatPlatform.find(params[:id])
  end

  def set_wechat_app
    @wechat_app = @wechat_platform.wechat_agencies.find_by(appid: params[:appid]).wechat_app
  end

end
