module Wechat
  class Panel::WechatUsersController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:identity, :uid, :unionid, :external_userid, :pending_id, :appid, :name)

      @wechat_users = WechatUser.default_where(q_params).order(id: :desc).page(params[:page])
    end

  end
end