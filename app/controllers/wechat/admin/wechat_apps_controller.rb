class Wechat::Admin::WechatAppsController < Wechat::Admin::BaseController
  before_action :set_wechat_app, only: [:show, :info, :edit, :edit_help, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:id)

    @wechat_apps = WechatApp.default_where(q_params).order(id: :asc).page(params[:page])
  end

  def own
    q_params = {}
    q_params.merge! organ_id: nil, allow: { organ_id: nil }

    @wechat_apps = WechatApp.default_where(q_params).order(id: :asc)
    render 'index'
  end

  def new
    @wechat_app = WechatApp.new
  end

  def create
    @wechat_app = WechatApp.find_or_initialize_by(appid: wechat_app_params[:appid])
    if @wechat_app.organ
      @wechat_app.errors.add :base, '该账号已在其他组织添加，请联系客服'
    end
    @wechat_app.assign_attributes wechat_app_params

    unless @wechat_app.save
      render :new, locals: { model: @wechat_app }, status: :unprocessable_entity
    end
  end

  def show
  end

  def info
  end

  def edit
  end

  def update
    @wechat_app.assign_attributes(wechat_app_params)

    unless @wechat_app.save
      render :edit, locals: { model: @wechat_app }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_app.destroy
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.default_where(default_params).find(params[:id])
  end

  def wechat_app_params
    p = params.fetch(:wechat_app, {}).permit(
      :type,
      :name,
      :enabled,
      :primary,
      :appid,
      :secret,
      :agentid,
      :mch_id,
      :key,
      :encrypt_mode
    )
    p.merge! default_form_params
  end

end
