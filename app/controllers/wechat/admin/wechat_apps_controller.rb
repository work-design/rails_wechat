class Wechat::Admin::WechatAppsController < Wechat::Admin::BaseController
  before_action :set_wechat_app, only: [:show, :info, :edit, :edit_help, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]

  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:id)
    @wechat_apps = WechatApp.default_where(q_params).order(id: :asc)
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
    @wechat_app = WechatApp.new(wechat_app_params)

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

  def edit_help

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

  def prepare_form
    q = { organ_id: nil }
    if defined?(current_organ) && current_organ
      q.merge! organ_id: [current_organ.id, nil]
    end
    @extractors = Extractor.default_where(q)
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
      :encrypt_mode,
      :help_without_user,
      :help_user_disabled,
      extractor_ids: []
    )
    p.merge! default_form_params
  end

end
