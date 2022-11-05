module Wechat
  class Panel::ProvidersController < Panel::BaseController

    private
    def provider_params
      _p = params.fetch(:provider, {}).permit(
        :name,
        :corp_id,
        :provider_secret
      )
      _p[:provider_secret]&.strip!
      _p
    end

  end
end
