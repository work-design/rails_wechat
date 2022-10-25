module Wechat
  class AppConfigsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_app

    def index
      @app_configs = @app.app_configs.pluck(:key, :value).to_h

      render json: @app_configs
    end

    private
    def set_app
      appid = request.user_agent&.scan /(?<=miniProgram\/).+$/
      @app = App.find_by(appid: appid[0])
    end

  end
end
