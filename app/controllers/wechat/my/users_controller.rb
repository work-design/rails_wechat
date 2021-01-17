module Wechat
  class My::UsersController < My::BaseController

    def invite_qrcode
      @qrcode_url = current_user.invite_qrcode(current_wechat_app)
    end

  end
end
