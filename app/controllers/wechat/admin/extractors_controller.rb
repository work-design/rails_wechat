module Wechat
  class Admin::ExtractorsController < Admin::BaseController
    before_action :set_response
    before_action :set_extractor, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}

      @extractors = @response.extractors.default_where(q_params).page(params[:page])
    end

    def new
      @extractor = @response.extractors.build
    end

    def create
      @extractor = @response.extractors.build(extractor_params)

      unless @extractor.save
        render :new, locals: { model: @extractor }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @extractor.assign_attributes(extractor_params)

      unless @extractor.save
        render :edit, locals: { model: @extractor }, status: :unprocessable_entity
      end
    end

    def destroy
      @extractor.destroy
    end

    private
    def set_response
      @response = Response.find params[:response_id]
    end

    def set_extractor
      @extractor = @response.extractors.find(params[:id])
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
