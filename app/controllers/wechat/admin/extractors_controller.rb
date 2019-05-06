class Wechat::Admin::ExtractorsController < Wechat::Admin::BaseController
  before_action :set_extractor, only: [:show, :edit, :update, :destroy]

  def index
    @extractors = Extractor.page(params[:page])
  end

  def new
    @extractor = Extractor.new
  end

  def create
    @extractor = Extractor.new(extractor_params)

    respond_to do |format|
      if @extractor.save
        format.html.phone
        format.html { redirect_to admin_extractors_url }
        format.js { redirect_back fallback_location: admin_extractors_url }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_extractors_url }
        format.json { render :show }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    @extractor.assign_attributes(extractor_params)

    respond_to do |format|
      if @extractor.save
        format.html.phone
        format.html { redirect_to admin_extractors_url }
        format.js { redirect_back fallback_location: admin_extractors_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_extractors_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @extractor.destroy
    redirect_to admin_extractors_url
  end

  private
  def set_extractor
    @extractor = Extractor.find(params[:id])
  end

  def extractor_params
    params.fetch(:extractor, {}).permit(
      :name,
      :separator,
      :match_value,
      :direction
    )
  end

end
