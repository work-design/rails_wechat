module Wechat
  class Panel::AgenciesController < Panel::BaseController
    before_action :set_platform
    before_action :set_agency, only: [:show, :edit, :update]

    def index
      @agencies = @platform.agencies.order(id: :desc).page(params[:page])
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
        :default
      )
    end

  end
end
