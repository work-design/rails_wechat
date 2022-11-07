module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      @corps = @suite.corps.page(params[:page])
    end

  end
end
