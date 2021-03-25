module Wechat
  class Admin::BaseController < AdminController

    private
    def set_app
      @app = App.find(params[:app_id])
    end

  end
end
