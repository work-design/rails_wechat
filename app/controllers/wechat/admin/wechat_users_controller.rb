module Wechat
  class Admin::WechatUsersController < Admin::BaseController
    before_action :set_app
    before_action :set_wechat_user, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit('wechat_user_tags.tag_id')

      @wechat_users = @app.wechat_users.default_where(q_params).page(params[:page])
    end

    def show
    end

    def edit
      @tags = @app.tags
    end

    def update
      @wechat_user.assign_attributes(wechat_user_params)

      unless @wechat_user.save
        render :edit, locals: { model: @wechat_user }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_user.destroy
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
