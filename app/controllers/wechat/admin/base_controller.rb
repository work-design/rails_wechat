module Wechat
  class Admin::BaseController < AdminController

    private
    def set_app
      @app = Agency.find_by(appid: params[:appid])
    end

  end
end
