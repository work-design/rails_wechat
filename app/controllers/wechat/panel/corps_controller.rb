module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      q_params = {}
      q_params.merge! params.permit('name-like', :corpid)

      @corps = @suite.corps.default_where(q_params).order(id: :desc).page(params[:page])
    end

  end
end
