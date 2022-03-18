module Wechat
  class Me::ExternalsController < Me::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @externals = current_corp_user.externals.default_where(q_params).page(params[:page])
    end

  end
end
