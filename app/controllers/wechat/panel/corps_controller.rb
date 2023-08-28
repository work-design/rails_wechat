module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp, only: [:show, :edit, :update, :organ]

    def index
      q_params = {}
      q_params.merge! params.permit('name-like', :corpid)

      @corps = @suite.corps.includes(:organ).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
    end

    private
    def set_corp
      @corp = @suite.corps.find params[:id]
    end

  end
end
