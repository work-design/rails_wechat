module Wechat
  class ProgramUsersController < BaseController
    before_action :set_app, only: [:create, :mobile]
    before_action :set_wechat_program_user, only: [:info, :mobile]
    skip_before_action :verify_authenticity_token if whether_filter(:verify_authenticity_token)

    def create
      @program_user = @app.generate_wechat_user(params[:code])
      @program_user.save
      @program_user.auth_appid = params[:auth_appid]

      headers['Authorization'] = @program_user.auth_token
      r = {
        auth_token: @program_user.auth_token,
        program_user: @program_user.as_json(only: [:name, :avatar_url, :uid, :unionid, :identity]),
        user: @program_user.user.as_json(only: [:name], methods: [:avatar_url])
      }
      if params[:state].present?
        state = Com::State.find_by(id: params[:state])
        if state
          state.destroyable = true
          state.save
          r.merge! url: state.url(auth_token: @program_user.auth_token)
        elsif @app.respond_to? :webview_url
          r.merge! url: @app.webview_url(auth_jwt_token: @program_user.auth_jwt_token)
        end
      elsif @app.respond_to? :webview_url
        r.merge! url: @app.webview_url(auth_token: @program_user.auth_token)
      end

      render json: r
    end

    def mobile
      if @program_user && @program_user.get_phone_number!(session_params)
        r = {}
        r.merge! url: @app.webview_url if @app.respond_to? :webview_url
        render json: r
      else
        render :mobile_err, locals: { model: @program_user }, status: :unprocessable_entity
      end
    end

    def info
      @program_user.name = userinfo_params[:nickName]
      @program_user.avatar_url = userinfo_params[:avatarUrl]
      @program_user.extra = userinfo_params.slice(:gender, :language, :city, :province, :country)
      @program_user.save

      render json: { url: url }
    end

    private
    def set_app
      @app = App.find_by(appid: params[:appid]) || Agency.find_by(appid: params[:appid])
    end

    def set_wechat_program_user
      @program_user = current_authorized_token.oauth_user
    end

    def session_params
      params.permit(
        :code,
        :encryptedData,
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
