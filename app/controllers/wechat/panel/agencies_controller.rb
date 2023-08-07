module Wechat
  class Panel::AgenciesController < Panel::BaseController
    before_action :set_platform
    before_action :set_agency, only: [:show, :edit, :update, :qrcode, :organ]

    def index
      q_params = {
        type: 'Wechat::PublicAgency'
      }
      q_params.merge! params.permit()

      @agencies = @platform.agencies.includes(organ: :organ_domains).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def search
      @agencies = @platform.agencies.default_where('nick_name-like': params['name-like'])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
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
        :logo,
        :organ_id
      )
    end

  end
end
