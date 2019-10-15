class Wechat::WechatProgramUsersController < Wechat::BaseController
  before_action :set_wechat_app, only: [:create, :bind_mobile]
  
  def create
    info = @wechat_app.api.jscode2session(session_params[:code])
    @wechat_program_user = WechatProgramUser.find_or_initialize_by(uid: info['openid'])
    union_id = info['unionId']

    @wechat_program_user.save
    
    render json: { token: @wechat_program_user.auth_token }
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

  def bind_mobile
    session_key = current_session.session_key
    
    user_phone_number_data = @wechat_app.get_phone_number(params[:encrypted_data], params[:iv], session_key)
    
    
    current_user.update! mobile: user_phone_number_data['purePhoneNumber']
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
