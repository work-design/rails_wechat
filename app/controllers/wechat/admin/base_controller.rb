class Wechat::Admin::BaseController < AdminController

  private
  def set_wechat_app
    @wechat_app = WechatApp.default_where(default_params).find(params[:wechat_app_id])
  end

end unless defined? Wechat::Admin::BaseController
