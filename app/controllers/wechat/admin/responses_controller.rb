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

      @responses = @app.responses.default_where(q_params).order(id: :desc).page(params[:page])
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

    def edit_reply
      q_params = {
        appid: @app.appid
      }
      q_params.merge! type: @response.reply.type if @response.reply

      @replies = Reply.where(q_params)
    end

    def filter_reply
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
