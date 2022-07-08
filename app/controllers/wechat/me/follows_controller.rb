module Wechat
  class Me::FollowsController < Me::BaseController
    before_action :set_follow, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! params.permit(:state, 'remark-like')

      @follows = current_corp_user.follows.includes(:client).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_follow
      @follow = current_corp_user.follows.find params[:id]
    end

  end
end
