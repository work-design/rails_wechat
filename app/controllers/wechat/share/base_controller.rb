module Wechat
  class Share::BaseController < AdminController

    private
    def set_wechat_app
      @app = App.shared.find_by id: params[:wechat_app_id]
    end

  end
end
