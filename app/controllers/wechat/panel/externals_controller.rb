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
      @corp = Corp.find_by corp_id: params[:corp_id], suite_id: params[:suite_id]
    end
  end
end
