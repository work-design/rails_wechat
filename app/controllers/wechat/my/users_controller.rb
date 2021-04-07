module Wechat
  class My::UsersController < My::BaseController

    def invite_qrcode
      @scene = current_user.invite_scene(current_wechat_app)
    end

    def requests
      @scene = current_user.invite_scene(current_wechat_app)
      if @scene.tag
        @requests =  @scene.tag.requests.page(params[:page]).per(3)
      else
        @requests = Request.none
      end
    end

  end
end
