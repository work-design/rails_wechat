module Wechat
  class Into::BaseController < IntoController

    private
    def set_app
      @app = App.shared.find params[:app_id]
    end

  end
end
