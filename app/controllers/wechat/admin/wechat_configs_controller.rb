class Wechat::Admin::WechatConfigsController < Wechat::Admin::BaseController
  before_action :set_wechat_config, only: [:show, :edit, :edit_help, :update, :destroy]

  def index
    @wechat_configs = current_organ.wechat_configs
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
    @wechat_config = current_organ.wechat_configs.find(params[:id])
  end
  
  def wechat_config_params
    params.fetch(:wechat_config, {}).permit(
      :account,
      :enabled,
      :appid,
      :secret,
      :corpid,
      :corpsecret,
      :agentid,
      :encrypt_mode,
      :encoding_aes_key,
      :token,
      :timeout,
      :help,
      :help_without_user,
      :help_user_disabled,
      :help_feedback
    )
  end

end
