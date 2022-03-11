module Wechat
  class My::MediasController < My::BaseController
    before_action :set_media, only: [:show, :edit, :update, :destroy]

    def index
      @media = Media.page(params[:page])
    end

    def new
      @media = Media.new
    end

    def create
      @media = Media.new(media_params)
      @media.appid = current_wechat_app.appid
      @media.user_id = current_user.id

      unless @media.save
        render :new, locals: { model: @media }, status: :unprocessable_entity
      end
    end

    private
    def set_media
      @media = Media.find(params[:id])
    end

    def media_params
      params.fetch(:media, {}).permit(
        :source_type,
        :source_id,
        :media_id,
        :attachment_name
      )
    end

  end
end
