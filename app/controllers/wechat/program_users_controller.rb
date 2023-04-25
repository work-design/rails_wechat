module Wechat
  class ProgramUsersController < BaseController
    before_action :set_app, only: [:create]
    before_action :set_wechat_program_user, only: [:info, :mobile]
    skip_before_action :verify_authenticity_token if whether_filter(:verify_authenticity_token)

    def create
      @program_user = @app.generate_wechat_user(params[:code])
      @program_user.user || @program_user.build_user
      @program_user.save

      headers['Authorization'] = auth_token.id
      render json: { auth_token: auth_token.id, user: @program_user.user }
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

      render json: { program_user: @program_user.as_json(only: [:id, :identity, :name, :avatar_url]) }
    end

    def mobile
      session_key = current_authorized_token&.session_key
      r = Wechat::Cipher.program_decrypt(params[:encryptedData], params[:iv], session_key)
      phone_number = r['phoneNumber']

      if session_key && phone_number
        @program_user.identity = phone_number
        @account = @program_user.account || @program_user.build_account(type: 'Auth::MobileAccount')
        @account.confirmed = true
        @account.user || @account.build_user
        @account.user.assign_attributes name: @program_user.name, invited_code: params[:invited_code]

        @program_user.class.transaction do
          @program_user.save!
          @account.save!
        end

        render json: { program_user: @program_user.as_json(only: [:id, :identity]), user: @program_user.user }
      else
        current_authorized_token&.destroy  # 触发重新授权逻辑
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
