module Wechat
  class Panel::BaseController < PanelController

    private
    def set_platform
      @platform = Platform.find params[:platform_id]
    end

    def set_app
      @app = App.find(params[:app_id])
      @platform = @app.platform
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
