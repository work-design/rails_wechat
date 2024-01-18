module Wechat
  class Panel::ReceivesController < Panel::BaseController
    before_action :set_platform

    def index
      q_params = {}
      q_params.merge! params.permit(:appid, :open_id)

      @receives = @platform.receives.default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_platform
      @platform = Platform.find params[:platform_id]
    end

  end
end
