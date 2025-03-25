module Wechat
  class Panel::RequestsController < Panel::BaseController
    before_action :set_app
    before_action :set_request, only: [:show, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:type, 'created_at-gte', 'created_at-lte')
      if q_params['created_at-lte']
        q_params['created_at-lte'] = q_params['created_at-lte'].to_time.end_of_day
      end
      @requests = @app.requests.includes(wechat_user: :user, extractions: :extractor).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_request
      @request = @app.requests.find(params[:id])
    end

  end
end
