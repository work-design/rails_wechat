module Wechat
  class Panel::SuitesController < Panel::BaseController
    before_action :set_provider
    before_action :set_new_suite, only: [:new, :create]

    def index
      @suites = @provider.suites.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end

    def set_new_suite
      @suite = @provider.suites.build(suite_params)
    end

    def suite_params
      params.fetch(:suite, {}).permit!
    end

  end
end