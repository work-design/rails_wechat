module Wechat
  class Panel::ProvidersController < Panel::BaseController


    private
    def provider_params
      p = params.fetch(:provider, {}).permit(
        :name,
        :corp_id,
        :provider_secret
      )
      p[:provider][:provider_secret].strip!
      p
    end

  end
end
