module Wechat
  class Share::BaseController < AdminController

    private
    def set_app
      @app = App.shared.find_by id: params[:app_id]
    end

  end
end
