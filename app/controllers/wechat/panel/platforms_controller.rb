module Wechat
  class Panel::PlatformsController < Panel::BaseController

    private
    def platform_params
      params.fetch(:platform, {}).permit(
        :name,
        :domain,
        :appid,
        :secret,
        :verify_ticket,
        :token,
        :encoding_aes_key
      )
    end

  end
end
