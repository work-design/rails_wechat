module Wechat
  class Panel::PlatformReceivesController < Panel::BaseController
    before_action :set_platform

    def index
      @platform_receives = @platform.receives.order(id: :desc).page(params[:page])
    end

    private
    def set_platform
      @platform = Platform.find params[:platform_id]
    end

  end
end
