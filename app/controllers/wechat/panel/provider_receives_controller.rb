module Wechat
  class Panel::ProviderReceivesController < Panel::BaseController
    before_action :set_provider

    def index
      @provider_receives = @provider.provider_receives.order(id: :desc).page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end
  end
end
