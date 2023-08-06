module Wechat
  class Admin::BaseController < AdminController

    private
    def set_app
      @app = Agency.find_by(appid: params[:app_appid])
    end

  end
end
