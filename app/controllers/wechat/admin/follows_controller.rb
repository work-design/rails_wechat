module Wechat
  class Admin::FollowsController < Admin::BaseController
    before_action :set_corp_user
    before_action :set_follow, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:state, :userid)

      @follows = @corp_user.follows.includes(:client).page(params[:page])
    end

    def sync
      @corp_user.sync_externals
    end

    private
    def set_corp_user
      @corp_user = CorpUser.find params[:corp_user_id]
    end

    def set_follow
      @follow = @corp_user.follows.find params[:id]
    end

  end
end
