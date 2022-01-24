module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider

    def index
      @corps = @provider.corps.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find params[:provider_id]
    end

  end
end
