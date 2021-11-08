module Wechat
  class Admin::WechatUsersController < Admin::BaseController
    before_action :set_app
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit('wechat_user_tags.tag_id', :name, :uid)

      @wechat_users = @app.wechat_users.includes(:account, :user, user_tags: :tag).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def edit
      @tags = @app.tags
    end

    private
    def set_wechat_user
      @wechat_user = @app.wechat_users.find params[:id]
    end

    def wechat_user_params
      params.fetch(:wechat_user, {}).permit(
        :name,
        :remark,
        tag_ids: []
      )
    end

  end
end
