class Wechat::WechatController < Wechat::BaseController
  skip_before_action :verify_authenticity_token

  def auth
    @wechat_user = WechatUser.find_or_initialize_by(uid: params[:openid])
    @wechat_user.assign_attributes params.permit(:access_token, :refresh_token, :app_id)
    @wechat_user.sync_user_info
    @wechat_user.account = current_account if current_account
    @wechat_user.save

    if @wechat_user.user
      login_by_wechat_user(@wechat_user)
      render 'auth'
    else
      render json: { oauth_user_id: @wechat_user.id }
    end
  end

  def wx_notice
    @wechat_ticket = WechatTicket.new(ticket_params)
    r = Hash.from_xml(request.body.read)['xml']
    @wechat_ticket.appid = r['AppId']
    @wechat_ticket.ticket_data = r['Encrypt']

    if @wechat_ticket.save
      render plain: 'success'
    else
      head :no_content
    end
  end

  def login_by_wechat_user(oauth_user)
    headers['Auth-Token'] = oauth_user.account.auth_token
    oauth_user.user.update(last_login_at: Time.now)

    logger.debug "Login by oauth user as user: #{oauth_user.user_id}"
    @current_oauth_user = oauth_user
    @current_user = oauth_user.user
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

end
