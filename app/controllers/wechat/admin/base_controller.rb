class Wechat::Admin::BaseController < AdminController
  
  private
  def set_wechat_config
    @wechat_config = current_organ.wechat_configs.find(params[:wechat_config_id])
  end
  
end
