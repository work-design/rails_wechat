module Wechat
  class Admin::ResponsesController < Admin::BaseController
    before_action :set_app
    before_action :set_response, only: [:show, :edit, :edit_reply, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {
        type: ['TextResponse', 'PersistScanResponse', 'EventResponse']
      }
      q_params.merge! params.permit(:type)

      @responses = @app.responses.includes(:response_requests).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @response = @app.responses.build
    end

    def create
      @response = @app.responses.build(response_params)

      unless @response.save
        render :new, locals: { model: @response }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def edit_reply
      q_params = {
        appid: @app.appid,
        type: @response.effective_type
      }

      @replies = Reply.where(q_params)
    end

    def update
      @response.assign_attributes(response_params)

      unless @response.save
        render :edit, locals: { model: @response }, status: :unprocessable_entity
      end
    end

    def destroy
      @response.destroy
    end

    private
    def set_response
      @response = @app.responses.find(params[:id])
    end

    def prepare_form
      q = { organ_id: nil }
      if defined?(current_organ) && current_organ
        q.merge! organ_id: [current_organ.id, nil]
      end
      @extractors = Extractor.default_where(q)
    end

    def response_params
      params.fetch(:response, {}).permit(
        :match_value,
        :contain,
        :expire_at,
        :effective_type,
        :effective_id,
        request_types: [],
        response_requests_attributes: {}
      )
    end

  end
end
