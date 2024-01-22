module Wechat
  class Admin::ScenesController < Panel::ScenesController
    include Controller::Admin

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:handle_type, :handle_id)

      @scenes = @app.scenes.default_where(q_params).order(id: :desc).page(params[:page])
    end

  end
end
