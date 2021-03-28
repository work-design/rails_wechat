module Wechat
  class My::UsersController < My::BaseController

    def invite_qrcode
      @scene = current_user.invite_scene(current_wechat_app)
    end

  end
end
