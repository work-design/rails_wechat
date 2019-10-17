class Wechat::WechatProgramUsersController < Wechat::BaseController
  before_action :set_wechat_app, only: [:create]
  
  def create
    info = @wechat_app.api.jscode2session(session_params[:code])
    @wechat_program_user = WechatProgramUser.find_or_initialize_by(uid: info['openid'])
    @wechat_program_user.app_id = params[:appid]
    union_id = info['unionId']
    
    begin
      @wechat_program_user.save
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      @wechat_program_user = WechatProgramUser.find_by(uid: info['openid'])
    end
    
    render json: { token: @wechat_program_user.auth_token(info['session_key']) }
  end

  def userinfo
    current_user.profile.update!(
      nick_name: userinfo_params[:nickName],
      gender: userinfo_params[:gender],
      language: userinfo_params[:language],
      city: userinfo_params[:city],
      province: userinfo_params[:province],
      country: userinfo_params[:country],
      avatar_url: userinfo_params[:avatarUrl]
    )
  end

  def mobile
    session_key = current_authorized_token.session_key
    @wechat_app = WechatApp.find_by(appid: current_authorized_token.oauth_user.app_id)
    phone_number = @wechat_app.get_phone_number(params[:encrypted_data], params[:iv], session_key)

    @account = Account.find_by(identity: phone_number) || Account.create_with_identity(phone_number)
    current_authorized_token.update(account_id: @account.id)
    @account.join
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.find_by(appid: params[:appid])
  end
  
  def session_params
    params.permit(
      :code,
      :encrypted_data,
      :iv
    )
  end

  def userinfo_params
    params.require(:userInfo).permit(
      :nickName,
      :gender,
      :language,
      :city,
      :province,
      :country,
      :avatarUrl
    )
  end
  
end
