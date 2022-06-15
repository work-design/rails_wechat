module Wechat
  class In::BaseController < InController

    private
    def set_app
      @app = App.shared.find params[:app_id]
    end

  end
end
