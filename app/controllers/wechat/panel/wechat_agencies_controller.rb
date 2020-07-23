class Wechat::Panel::WechatAgenciesController < Wechat::Panel::BaseController
  before_action :set_wechat_agency, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_agencies = @wechat_platform.wechat_agencies.page(params[:page])
  end

  def new
    @wechat_agency = @wechat_platform.wechat_agencies.build
  end

  def create
    @wechat_agency = @wechat_platform.wechat_agencies.build(wechat_agency_params)

    unless @wechat_agency.save
      render :new, locals: { model: @wechat_agency }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_agency.assign_attributes(wechat_agency_params)

    unless @wechat_agency.save
      render :edit, locals: { model: @wechat_agency }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_agency.destroy
  end

  private
  def set_wechat_platform
    @wechat_platform = WechatPlatform.find params[:wechat_platform_id]
  end

  def set_wechat_agency
    @wechat_agency = WechatAgency.find(params[:id])
  end

  def wechat_agency_params
    params.fetch(:wechat_agency, {}).permit(
      :appid,
      :access_token,
      :access_token_expires_at,
      :refresh_token,
      :func_infos
    )
  end

end
