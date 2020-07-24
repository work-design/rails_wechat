class Wechat::WechatPlatformsController < Wechat::BaseController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_wechat_platform

  def show
  end

  def callback
    @wechat_auth = @wechat_platform.wechat_auths.build
    @wechat_auth.auth_code = params[:auth_code]
    @wechat_auth.auth_code_expires_at = Time.current + params[:expires_in].to_i
    @wechat_auth.save
  end

  def message
    @wechat_ticket = WechatTicket.new
    r = Hash.from_xml(request.body.read)['xml']
    @wechat_ticket.appid = r['AppId'] || params[:appid]
    @wechat_ticket.ticket_data = r['Encrypt']
    logger.debug "----------> #{r}"
    parsed_data(@wechat_ticket.ticket_data)

    if @wechat_ticket.save
      render plain: 'success'
    else
      head :no_content
    end
  end

  private
  def set_wechat_platform
    if params[:id]
      @wechat_platform = WechatPlatform.find(params[:id])
    else
      @wechat_platform = WechatPlatform.first
    end
  end

  def set_wechat_app
    @wechat_app = @wechat_platform.wechat_agencies.find_by(appid: params[:appid]).wechat_app
  end

  def parsed_data(ticket_data)
    r = Wechat::Cipher.decrypt(Base64.decode64(ticket_data), @wechat_platform.encoding_aes_key)
    content, _ = Wechat::Cipher.unpack(r)

    data = Hash.from_xml(content).fetch('xml', {})
    logger.debug "----------> #{data}"
    data
  end

end
