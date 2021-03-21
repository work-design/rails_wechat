module Wechat
  class Share::AppsController < Share::BaseController
    before_action :set_wechat_app, only: [:show]

    def index
      q_params = {}
      q_params.merge! params.permit(:id)

      @wechat_apps = App.shared.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def show
    end

    private
    def set_wechat_app
      @app = App.shared.find(params[:id])
    end

  end
end
