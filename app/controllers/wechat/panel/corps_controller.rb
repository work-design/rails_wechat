module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      @corps = @suite.corps.page(params[:page])
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
