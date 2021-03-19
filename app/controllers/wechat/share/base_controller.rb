module Wechat
  class Share::BaseController < AdminController

    private
    def set_wechat_app
      @wechat_app = WechatApp.shared.find_by appid: params[:appid]
    end

  end
end
