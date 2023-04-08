module Wechat
  class Admin::ExtractorsController < Admin::BaseController
    before_action :set_response
    before_action :set_extractor, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_extractor, only: [:new, :create]

    def index
      q_params = {}

      @extractors = @response.extractors.default_where(q_params).order(id: :asc).page(params[:page])
    end

    private
    def set_response
      @response = Response.find params[:response_id]
    end

    def set_extractor
      @extractor = @response.extractors.find(params[:id])
    end

    def set_new_extractor
      @extractor = @response.extractors.build(extractor_params)
    end

    def extractor_params
      params.fetch(:extractor, {}).permit(
        :name,
        :prefix,
        :suffix,
        :more,
        :serial,
        :serial_start,
        :start_at,
        :finish_at,
        :valid_response,
        :invalid_response
      )
    end

  end
end
