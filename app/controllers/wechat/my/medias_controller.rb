class Wechat::My::MediasController < Wechat::My::BaseController
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

  def show
  end

  def edit
  end

  def update
    @media.assign_attributes(media_params)

    unless @media.save
      render :edit, locals: { model: @media }, status: :unprocessable_entity
    end
  end

  def destroy
    @media.destroy
  end

  private
  def set_media
    @media = Medium.find(params[:id])
  end

  def media_params
    params.fetch(:media, {}).permit(
      :source_type,
      :source_id,
      :media_id,
      :attachment_name,
      :appid
    )
  end

end
