module Wechat
  class My::UsersController < My::BaseController

    def invite_qrcode
      @scene = current_user.invite_scene(current_wechat_app)
      if @scene.tag
        @requests = @scene.tag.requests.includes(:wechat_user).page(params[:page])
      else
        @requests = Request.none.page(params[:page])
      end
    end

  end
end
