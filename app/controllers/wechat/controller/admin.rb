module Wechat
  module Controller::Admin

    def set_app
      @app = current_organ.apps.find_by(appid: params[:app_appid])
    end

  end
end
