module Wechat
  class Panel::SuiteTicketsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      @suite_tickets = @suite.suite_tickets.order(id: :desc).page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find_by corp_id: params[:provider_id]
    end

    def set_suite
      @suite = Suite.find params[:suite_id]
    end
  end
end