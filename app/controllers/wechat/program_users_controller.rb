module Wechat
  class ProgramUsersController < BaseController
    before_action :set_app, only: [:create]
    before_action :set_wechat_program_user, only: [:info, :mobile]
    skip_before_action :verify_authenticity_token if whether_filter(:verify_authenticity_token)

    def create
      @program_user = @app.generate_wechat_user(params[:code])
      @program_user.save

      headers['Authorization'] = @program_user.auth_token
      render json: { auth_token: @program_user.auth_token, program_user: @program_user.as_json(methods: [:skip_auth, :only_auth]), user: @program_user.user }
    end

    def mobile
      if @program_user && @program_user.get_phone_number!(params)
        headers['Authorization'] = @program_user.auth_token
        render json: { auth_token: @program_user.auth_token, program_user: @program_user, user: @program_user.user }
      else
        current_authorized_token&.destroy  # 触发重新授权逻辑
        render :mobile_err, locals: { model: @program_user }, status: :unprocessable_entity
      end
    end

    def info
      @program_user.name = userinfo_params[:nickName]
      @program_user.avatar_url = userinfo_params[:avatarUrl]
      @program_user.extra = userinfo_params.slice(:gender, :language, :city, :province, :country)
      @program_user.save

      render json: { program_user: @program_user.as_json(only: [:id, :identity, :name, :avatar_url]) }
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
