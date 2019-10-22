class Wechat::WechatProgramUsersController < Wechat::BaseController
  before_action :set_wechat_app, only: [:create]
  before_action :set_wechat_program_user, only: [:info, :mobile]
  skip_before_action :verify_authenticity_token
  
  def create
    info = @wechat_app.api.jscode2session(session_params[:code])
    @wechat_program_user = WechatProgramUser.find_or_initialize_by(uid: info['openid'])
    @wechat_program_user.app_id = params[:appid]
    @wechat_program_user.unionid = info['unionId']
    
    begin
      @wechat_program_user.save!
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      @wechat_program_user = WechatProgramUser.find_by(uid: info['openid'])
    end
    
    render json: { token: @wechat_program_user.auth_token(info['session_key']) }
  end

  def info
    @wechat_program_user.name = userinfo_params[:nickName]
    @wechat_program_user.avatar_url = userinfo_params[:avatarUrl]
    @wechat_program_user.extra = {
      gender: userinfo_params[:gender],
      language: userinfo_params[:language],
      city: userinfo_params[:city],
      province: userinfo_params[:province],
      country: userinfo_params[:country],
    }
    
    @wechat_program_user.save
  end

  def mobile
    session_key = current_authorized_token.session_key
    phone_number = @wechat_program_user.get_phone_number(params[:encrypted_data], params[:iv], session_key)
    if phone_number
      @account = Account.find_by(identity: phone_number) || Account.create_with_identity(phone_number)
      current_authorized_token.update(account_id: @account.id)
      @wechat_program_user.update(account_id: @account.id)
      @account.join(name: @wechat_program_user.name)
    else
      current_authorized_token.destroy
    end
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.find_by(appid: params[:appid])
  end
  
  def set_wechat_program_user
    @wechat_program_user = current_authorized_token.oauth_user
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
