module Wechat
  class Admin::FollowsController < Admin::BaseController
    before_action :set_corp_user

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
  end
end
