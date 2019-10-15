class Wechat::SessionsController < Wechat::BaseController
  before_action :set_wechat_app, only: [:create, :bind_mobile]
  
  def create
    info = @wechat_app.api.jscode2session(session_params)
    authorization = WechatProgramUser.find_or_initialize_by(uid: info['openid'])
    union_id = info.dig(:unionId)

    # 未登录，小程序的登录页面发起的请求
    if authorization.blank?
      # 重新绑定账号的微信登录凭证
      begin
        ActiveRecord::Base.transaction do
          authorization = Authorization.create!(provider: :weapp, uid: info.fetch(:uid), union_id: union_id, user: user)
        end
      # 并发进入的线程, 在这里重新查找一次即可
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        authorization = Authorization.find_by!(provider: :weapp, uid: info.fetch(:uid))
      end

      # 检查更新无 union_id 的用户
      if union_id.present? && authorization.union_id.blank?
        authorization.update!(union_id: union_id)
        Authorization.where(union_id: union_id).each { |e| e.update!(user: authorization.user) }
      end

      # 登录成功
      session = authorization.user.sessions.create!(session_key: info.fetch(:session_key), authorization: authorization)
      render_created(token: Auth.encode(token: session.token))
      return
    end

    begin
      session = authorization.user.sessions.find_or_create_by!(session_key: info.fetch(:session_key), authorization: authorization)
    # 并发进入的线程, 在这里重新查找一次即可
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      session = authorization.user.sessions.find_by!(session_key: info.fetch(:session_key), authorization: authorization)
    end
    render_created(token: Auth.encode(token: session.token))
    
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
