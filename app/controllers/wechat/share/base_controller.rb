module Wechat
  class Share::BaseController < AdminController

    private
    def set_wechat_app
      @wechat_app = WechatApp.shared.find_by wechat_app_id: params[:wechat_app_id]
    end

  end
end
