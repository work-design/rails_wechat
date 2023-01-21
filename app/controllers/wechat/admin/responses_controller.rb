module Wechat
  class Admin::ResponsesController < Admin::BaseController
    before_action :set_app
    before_action :set_response, only: [:show, :edit, :edit_reply, :update, :destroy]
    before_action :set_new_response, only: [:new, :create]
    before_action :set_extractors, only: [:new, :create, :edit, :update]

    def index
      q_params = {
        type: ['TextResponse', 'PersistScanResponse', 'EventResponse']
      }
      q_params.merge! params.permit(:type)

      @responses = @app.responses.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def edit_reply
      q_params = {
        appid: @app.appid
      }
      q_params.merge! type: @response.reply.type if @response.reply

      @replies = Reply.where(q_params).page(params[:page])
    end

    def filter_reply
    end

    private
    def set_response
      @response = @app.responses.find(params[:id])
    end

    def set_new_response
      @response = @app.responses.build(response_params)
    end

    def set_extractors
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
        request_responses_attributes: {}
      )
    end

  end
end
