module Wechat
  class Panel::ProgramAgenciesController < Panel::BaseController
    before_action :set_platform
    before_action :set_program_agency, only: [:show, :edit, :update, :qrcode, :organ]

    def index
      q_params = {
        type: 'Wechat::ProgramAgency'
      }
      q_params.merge! params.permit()

      @program_agencies = @platform.agencies.includes(organ: :organ_domains).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def search
      @agencies = @platform.agencies.default_where('nick_name-like': params['name-like'])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
    end

    private
    def set_program_agency
      @program_agency = @platform.agencies.find(params[:id])
    end

    def agency_params
      params.fetch(:agency, {}).permit(
        :logo,
        :organ_id
      )
    end

  end
end