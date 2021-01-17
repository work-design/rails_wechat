module Wechat
  class Admin::WechatTagsController < Admin::BaseController
    before_action :set_wechat_app
    before_action :set_wechat_tag, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @wechat_tags = @wechat_app.wechat_tags.default_where(q_params).order(id: :asc).page(params[:page])
    end

    def new
      @wechat_tag = @wechat_app.wechat_tags.build
    end

    def create
      @wechat_tag = @wechat_app.wechat_tags.build(wechat_tag_params)

      unless @wechat_tag.save
        render :new, locals: { model: @wechat_tag }, status: :unprocessable_entity
      end
    end

    def sync
      @wechat_app.sync_wechat_tags
      redirect_to admin_wechat_app_wechat_tags_url(@wechat_app)
    end

    def show
    end

    def edit
    end

    def update
      @wechat_tag.assign_attributes(wechat_tag_params)

      unless @wechat_tag.save
        render :edit, locals: { model: @wechat_tag }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_tag.destroy
    end

    private
    def set_wechat_tag
      @wechat_tag = @wechat_app.wechat_tags.find(params[:id])
    end

    def wechat_tag_params
      params.fetch(:wechat_tag, {}).permit(
        :name,
        :tagging_type,
        :tagging_id
      )
    end

  end
end
