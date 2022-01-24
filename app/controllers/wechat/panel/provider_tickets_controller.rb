module Wechat
  class Panel::ProviderTicketsController < Panel::BaseController
    before_action :set_provider

    def index
      @provider_tickets = @provider.provider_tickets.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end
  end
end
