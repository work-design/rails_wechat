module Wechat
  class Panel::AgenciesController < Panel::BaseController
    before_action :set_platform
    before_action :set_agency, only: [:show, :edit, :update]

    def index
      q_params = {}
      q_params.merge! params.permit(:type)

      @agencies = @platform.agencies.includes(:app).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def search
      @agencies = @platform.agencies.default_where('nick_name-like': params['name-like'])
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
        :default,
        :domain
      )
    end

  end
end
