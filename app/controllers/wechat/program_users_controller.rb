module Wechat
  class ProgramUsersController < BaseController
    before_action :set_app, only: [:create]
    before_action :require_authorized_token, only: [:info, :mobile]
    before_action :set_wechat_program_user, only: [:info, :mobile]
    skip_before_action :verify_authenticity_token

    def create
      info = @app.api.jscode2session(session_params[:code])
      @program_user = ProgramUser.create_or_find_by!(uid: info['openid']) do |program_user|
        program_user.appid = params[:appid]
        program_user.unionid = info['unionId']
      end

      render json: { token: @program_user.auth_token(info['session_key']) }
    end

    def info
      @program_user.name = userinfo_params[:nickName]
      @program_user.avatar_url = userinfo_params[:avatarUrl]
      @program_user.extra = {
        gender: userinfo_params[:gender],
        language: userinfo_params[:language],
        city: userinfo_params[:city],
        province: userinfo_params[:province],
        country: userinfo_params[:country]
      }

      @program_user.save
    end

    def mobile
      session_key = current_authorized_token.session_key

      phone_number = @program_user.get_phone_number(params[:encrypted_data], params[:iv], session_key)
      if phone_number
        @account = Account.find_by(identity: phone_number) || Account.create_with_identity(phone_number)
        @account.confirmed = true
        @account.join(name: @program_user.name, invited_code: params[:invited_code])

        @program_user.account = @account
        current_authorized_token.account = @account

        @program_user.save
        current_authorized_token.save

        @program_user.reload
      else
        current_authorized_token.destroy  # 触发重新授权逻辑
        render :mobile_err, locals: { model: @program_user }, status: :unprocessable_entity
      end
    end

    private
    def set_app
      @app = App.find_by(appid: params[:appid])
    end

    def set_wechat_program_user
      @program_user = current_authorized_token.oauth_user
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
end
