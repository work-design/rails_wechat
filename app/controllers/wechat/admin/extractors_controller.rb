class Wechat::Admin::ExtractorsController < Wechat::Admin::BaseController
  before_action :set_extractor, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! default_params
    @extractors = Extractor.default_where(q_params).page(params[:page])
  end

  def new
    @extractor = Extractor.new
  end

  def create
    @extractor = Extractor.new(extractor_params)

    unless @extractor.save
      render :new, locals: { model: @extractor }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @extractor.assign_attributes(extractor_params)

    unless @extractor.save
      render :edit, locals: { model: @extractor }, status: :unprocessable_entity
    end
  end

  def destroy
    @extractor.destroy
  end

  private
  def set_extractor
    @extractor = Extractor.find(params[:id])
  end

  def extractor_params
    p = params.fetch(:extractor, {}).permit(
      :name,
      :prefix,
      :suffix,
      :more,
      :serial_start,
      :start_at,
      :finish_at,
      :valid_response,
      :invalid_response
    )
    p.merge! default_form_params
  end

end
