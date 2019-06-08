class Wechat::Admin::BaseController < AdminController
  
  private
  def set_wechat_config
    @wechat_config = WechatConfig.where(default_params).find(params[:wechat_config_id])
  end
  
end
