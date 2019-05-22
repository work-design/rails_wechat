class Wechat::Panel::BaseController < PanelController
  
  private
  def set_wechat_config
    @wechat_config = current_organ.wechat_configs.find(params[:wechat_config_id])
  end
  
end
