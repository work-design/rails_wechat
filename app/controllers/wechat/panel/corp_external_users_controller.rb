module Wechat
  class Panel::CorpExternalUsersController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:identity, :uid, :unionid, :external_userid, :pending_id, :appid, :name)

      @corp_external_users = CorpExternalUser.includes(:corp, wechat_user: :app).default_where(q_params).order(id: :desc).page(params[:page])
    end

  end
end
