module Wechat
  class Panel::BaseController < PanelController

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end

    def set_suite
      @suite = @provider.suites.find params[:suite_id]
    end

    def set_corp
      @corp = @suite.corps.find params[:corpid]
    end
  end
end
