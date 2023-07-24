module Wechat
  class Panel::PlatformsController < Panel::BaseController
    before_action :set_platform, only: [:show, :edit, :update, :destroy, :agency, :info]

    private
    def set_platform
      @platform = Platform.find params[:id]
    end

    def platform_params
      params.fetch(:platform, {}).permit(
        :name,
        :domain,
        :appid,
        :secret,
        :verify_ticket,
        :token,
        :encoding_aes_key,
        :public_agency_id,
        :program_agency_id
      )
    end

  end
end
