module Wechat
  class Me::FollowsController < Me::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:state)

      @follows = current_corp_user.follows.includes(:client).default_where(q_params).page(params[:page])
    end

  end
end
