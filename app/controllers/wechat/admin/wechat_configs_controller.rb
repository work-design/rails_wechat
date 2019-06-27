class Wechat::Admin::WechatConfigsController < Wechat::Admin::BaseController
  before_action :set_wechat_config, only: [:show, :info, :edit, :edit_help, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]
  
  def index
    q_params = {}
    q_params.merge! default_params
    q_params.merge! params.permit(:id)
    @wechat_configs = WechatConfig.default_where(q_params).order(id: :asc)
  end
  
  def own
    q_params = {}
    q_params.merge! organ_id: nil
    
    @wechat_configs = WechatConfig.default_where(q_params, { organ_id: { allow: [nil] }}).order(id: :asc)
    render 'index'
  end

  def new
    @wechat_config = WechatConfig.new
  end

  def create
    @wechat_config = WechatConfig.new(wechat_config_params)
  
    respond_to do |format|
      if @wechat_config.save
        format.html.phone
        format.html { redirect_to admin_wechat_configs_url }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      end
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
    @wechat_config.assign_attributes(wechat_config_params)

    respond_to do |format|
      if @wechat_config.save
        format.html.phone
        format.html { redirect_to admin_wechat_configs_url }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_back fallback_location: admin_wechat_configs_url }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_config.destroy
    redirect_to admin_wechat_configs_url
  end

  private
  def set_wechat_config
    @wechat_config = WechatConfig.where(default_params).find(params[:id])
  end
  
  def prepare_form
    q = { organ_id: nil }
    if current_organ
      q.merge! organ_id: [current_organ.id, nil]
    end
    @extractors = Extractor.default_where(q)
  end
  
  def wechat_config_params
    p = params.fetch(:wechat_config, {}).permit(
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
      :help,
      :help_without_user,
      :help_user_disabled,
      :help_feedback,
      extractor_ids: []
    )
    p.merge! default_params
  end

end
