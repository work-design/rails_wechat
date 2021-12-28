module Wechat
  class My::UsersController < My::BaseController
    before_action :set_scene

    def invite_qrcode
      if @scene.tag
        @requests = @scene.tag.requests.includes(:wechat_user).page(params[:page])
      else
        @requests = Request.none.page(params[:page])
      end
    end

    private
    def set_scene
      @scene = current_user.invite_scene(current_wechat_app)
    end

  end
end
