module Wechat
  class Panel::AgenciesController < Panel::BaseController
    before_action :set_platform
    before_action :set_agency, only: [:show, :edit, :update]

    def index
      @agencies = @platform.agencies.order(id: :desc).page(params[:page])
    end

    def show
    end

    def edit
    end

    def update
      @agency.assign_attributes(agency_params)

      unless @agency.save
        render :edit, locals: { model: @agency }, status: :unprocessable_entity
      end
    end

    private
    def set_platform
      @platform = Platform.find params[:platform_id]
    end

    def set_agency
      @agency = Agency.find(params[:id])
    end

    def agency_params
      params.fetch(:agency, {}).permit(
        :app
      )
    end

  end
end
