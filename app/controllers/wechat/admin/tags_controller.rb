module Wechat
  class Admin::TagsController < Admin::BaseController
    before_action :set_app
    before_action :set_tag, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @tags = @app.tags.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @tag = @app.tags.build
    end

    def create
      @tag = @app.tags.build(tag_params)

      unless @tag.save
        render :new, locals: { model: @tag }, status: :unprocessable_entity
      end
    end

    def sync
      @app.sync_tags
      redirect_to admin_app_tags_url(@app)
    end

    def show
    end

    def edit
    end

    def update
      @tag.assign_attributes(tag_params)

      unless @tag.save
        render :edit, locals: { model: @tag }, status: :unprocessable_entity
      end
    end

    def destroy
      @tag.destroy
    end

    private
    def set_tag
      @tag = @app.tags.find(params[:id])
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
