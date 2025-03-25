module Wechat
  class Panel::UserTagsController < Panel::BaseController
    before_action :set_app

    def index
      q_params = {}

      @user_tags = @app.user_tags.default_where(q_params).order(id: :desc).page(params[:page])
    end

  end
end
