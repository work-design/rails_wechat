module Wechat
  class Admin::TagsController < Admin::BaseController
    before_action :set_app
    before_action :set_tag, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_tag, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @tags = @app.tags.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def sync
      @app.sync_tags
    end

    private
    def set_tag
      @tag = @app.tags.find(params[:id])
    end

    def set_new_tag
      @tag = @app.tags.build(tag_params)
    end

    def tag_params
      params.fetch(:tag, {}).permit(
        :name,
        :tagging_type,
        :tagging_id
      )
    end

  end
end
