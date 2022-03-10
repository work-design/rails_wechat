module Wechat
  class Panel::PlatformsController < Panel::BaseController
    before_action :set_platform, only: [:show, :edit, :update, :destroy]

    def index
      @platforms = Platform.page(params[:page])
    end

    private
    def set_platform
      @platform = Platform.find(params[:id])
    end

    def platform_params
      params.fetch(:platform, {}).permit(
        :name,
        :appid,
        :secret,
        :verify_ticket,
        :token,
        :encoding_aes_key
      )
    end

  end
end
