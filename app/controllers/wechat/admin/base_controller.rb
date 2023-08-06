module Wechat
  class Admin::BaseController < AdminController

    private
    def set_app
      @app = App.find_by(appid: params[:app_appid])
    end

  end
end
