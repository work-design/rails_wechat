module Wechat
  class Admin::WechatResponsesController < Admin::BaseController
    before_action :set_app
    before_action :set_wechat_response, only: [:show, :edit, :edit_reply, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {
        type: ['TextResponse', 'PersistScanResponse', 'EventResponse']
      }
      q_params.merge! params.permit(:type)
      @wechat_responses = @app.wechat_responses.includes(:wechat_response_requests).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @wechat_response = @app.wechat_responses.build
    end

    def create
      @wechat_response = @app.wechat_responses.build(wechat_response_params)

      unless @wechat_response.save
        render :new, locals: { model: @wechat_response }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def edit_reply
      q_params = {
        appid: @app.appid,
        type: @wechat_response.effective_type
      }
      @wechat_replies = WechatReply.where(q_params)
    end

    def update
      @wechat_response.assign_attributes(wechat_response_params)

      unless @wechat_response.save
        render :edit, locals: { model: @wechat_response }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_response.destroy
    end

    private
    def set_wechat_response
      @wechat_response = @app.wechat_responses.find(params[:id])
    end

    def prepare_form
      q = { organ_id: nil }
      if defined?(current_organ) && current_organ
        q.merge! organ_id: [current_organ.id, nil]
      end
      @wechat_extractors = WechatExtractor.default_where(q)
    end

    def wechat_response_params
      params.fetch(:wechat_response, {}).permit(
        :match_value,
        :contain,
        :expire_seconds,
        :effective_type,
        :effective_id,
        request_types: [],
        wechat_response_requests_attributes: {}
      )
    end

  end
end
