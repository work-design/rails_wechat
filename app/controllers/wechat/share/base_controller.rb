module Wechat
  class Share::BaseController < AdminController

    private
    def set_app
      @app = App.shared.find params[:app_id]
    end

  end
end
