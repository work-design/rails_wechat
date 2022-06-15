module Wechat
  class Into::WechatUsersController < Into::BaseController
    before_action :set_app
    before_action :set_scene
    before_action :set_wechat_user, only: [:show, :edit, :update, :try_match, :destroy]

    def index
      q_params = {
        'user_tags.tag_name': @scene.match_value
      }
      q_params.merge! params.permit(:name)

      @wechat_users = @app.wechat_users.default_where(q_params).page(params[:page])
    end

    def edit
      @wechat_tags = @app.wechat_tags
    end

    def try_match
      @result = @wechat_user.try_match
    end

    private
    def set_scene
      @scene = Scene.find params[:scene_id]
    end

    def set_wechat_user
      @wechat_user = @app.wechat_users.find params[:id]
    end

    def wechat_user_params
      params.fetch(:wechat_user, {}).permit(
        :name,
        :remark,
        wechat_tag_ids: []
      )
    end

  end
end
