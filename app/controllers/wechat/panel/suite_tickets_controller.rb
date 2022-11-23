module Wechat
  class Panel::SuiteTicketsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      q_params = {}
      q_params.merge! params.permit(:info_type, :corpid)

      @suite_tickets = @suite.suite_tickets.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end

    def set_suite
      @suite = Suite.find params[:suite_id]
    end
  end
end
