module Wechat
  class Panel::BaseController < PanelController

    private
    def set_app
      @app = Agency.find_by(appid: params[:agency_id])
    end

    def set_provider
      @provider = Provider.find params[:provider_id]
    end

    def set_suite
      @suite = @provider.suites.find params[:suite_id]
    end

    def set_corp
      @corp = @suite.corps.find params[:corp_id]
    end
  end
end
