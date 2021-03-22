module Wechat
  class Admin::RequestsController < Admin::BaseController
    before_action :set_app
    before_action :set_request, only: [:show, :update, :destroy]

    def index
      q_params = {
        type: 'Wechat::TextRequest'
      }
      q_params.merge! params.permit('created_at-gte', 'created_at-lte', :type)
      if q_params['created_at-lte']
        q_params['created_at-lte'] = q_params['created_at-lte'].to_time.end_of_day
      end
      @requests = @app.requests.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def show
    end

    def update
      @request.assign_attributes(request_params)

      unless @request.save
        render :update, locals: { model: @request }, status: :unprocessable_entity
      end
    end

    def destroy
      @request.destroy
    end

    private
    def set_request
      @request = @app.requests.find(params[:id])
    end

  end
end
