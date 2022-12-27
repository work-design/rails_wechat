module Wechat
  class Panel::CorpsController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite

    def index
      @corps = @suite.corps.order(id: :desc).page(params[:page])
    end

  end
end
