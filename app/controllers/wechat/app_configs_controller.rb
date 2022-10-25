module Wechat
  class AppConfigsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_app

    def index
      if @app
        result = @app.app_configs.pluck(:key, :value).to_h
      else
        result = {}
      end

      render json: result
    end

    private
    def set_app
      appid = request.user_agent&.scan /(?<=miniProgram\/).+$/
      if appid.present?
        @app = App.find_by(appid: appid[0])
      else
        @app = App.find_by appid: params[:appid]
      end
    end

  end
end
