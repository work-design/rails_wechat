module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      q_params = {}
      q_params.merge! params.permit('name-like', :corpid)

      @corps = @suite.corps.includes(:organ).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def search_organs
      @organs = Org::Organ.default_where('name-like': params['name-like'])
    end

  end
end
