module Wechat
  class My::UsersController < My::BaseController

    def invite_qrcode
      scene = current_user.invite_scene(current_wechat_app)
      @qrcode_url = scene.qrcode_file_url
    end

  end
end
