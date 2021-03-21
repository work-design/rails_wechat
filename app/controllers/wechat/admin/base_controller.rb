module Wechat
  class Admin::BaseController < AdminController

    private
    def set_app
      @app = App.default_where(default_params).find(params[:app_id])
    end

  end
end
