module Wechat
  class In::AppsController < In::BaseController
    before_action :set_app, only: [:show]

    def index
      q_params = {}
      q_params.merge! params.permit(:id)

      @apps = App.default_where(q_params).order(id: :asc).page(params[:page])
    end

  end
end
