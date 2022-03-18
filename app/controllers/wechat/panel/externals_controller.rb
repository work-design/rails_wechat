module Wechat
  class Panel::ExternalsController < Panel::BaseController
    before_action :set_corp

    def index
      q_params = {}
      q_params.merge! params.permit(:state, :userid)

      @externals = @corp.externals.default_where(q_params).page(params[:page])
    end

    private
    def set_corp
      @corp = Corp.find params[:corp_id]
    end
  end
end
