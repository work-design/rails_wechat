class Wechat::Admin::WechatExtractorsController < Wechat::Admin::BaseController
  before_action :set_wechat_response
  before_action :set_wechat_extractor, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    @wechat_extractors = @wechat_response.wechat_extractors.default_where(q_params).page(params[:page])
  end

  def new
    @wechat_extractor = @wechat_response.wechat_extractors.build
  end

  def create
    @wechat_extractor = @wechat_response.wechat_extractors.build(wechat_extractor_params)

    unless @wechat_extractor.save
      render :new, locals: { model: @wechat_extractor }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_extractor.assign_attributes(wechat_extractor_params)

    unless @wechat_extractor.save
      render :edit, locals: { model: @wechat_extractor }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_extractor.destroy
  end

  private
  def set_wechat_response
    @wechat_response = WechatResponse.find params[:wechat_response_id]
  end

  def set_wechat_extractor
    @wechat_extractor = @wechat_response.wechat_extractors.find(params[:id])
  end

  def wechat_extractor_params
    params.fetch(:wechat_extractor, {}).permit(
      :name,
      :prefix,
      :suffix,
      :more,
      :serial,
      :serial_start,
      :start_at,
      :finish_at,
      :valid_response,
      :invalid_response
    )
  end

end
