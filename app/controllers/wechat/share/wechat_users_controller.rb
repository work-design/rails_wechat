module Wechat
  class Share::WechatUsersController < Share::BaseController
    before_action :set_app
    before_action :set_scene
    before_action :set_wechat_user, only: [:show, :edit, :update, :try_match, :destroy]

    def index
      q_params = {
        'wechat_user_tags.tag_id': @scene.tag&.id
      }

      @wechat_users = @app.wechat_users.default_where(q_params).page(params[:page])
    end

    def show
    end

    def edit
      @wechat_tags = @app.wechat_tags
    end

    def update
      @wechat_user.assign_attributes(wechat_user_params)

      unless @wechat_user.save
        render :edit, locals: { model: @wechat_user }, status: :unprocessable_entity
      end
    end

    def try_match
      @result = @wechat_user.try_match
    end

    def destroy
      @wechat_user.destroy
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
