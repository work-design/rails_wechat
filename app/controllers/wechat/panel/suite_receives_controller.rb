module Wechat
  class Panel::SuiteReceivesController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      @provider_receives = @suite.provider_receives.order(id: :desc).page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find corp_id: params[:provider_id]
    end

    def set_suite
      @suite = Suite.find params[:suite_id]
    end

  end
end
