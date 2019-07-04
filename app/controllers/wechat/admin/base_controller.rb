class Wechat::Admin::BaseController < AdminController
  
  private
  def set_wechat_app
    @wechat_app = WechatApp.where(default_params).find(params[:wechat_app_id])
  end
  
end
