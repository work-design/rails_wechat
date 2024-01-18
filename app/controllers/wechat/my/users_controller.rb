module Wechat
  class My::UsersController < My::BaseController
    before_action :set_scene

    def invite_qrcode
      @requests = @scene.requests.includes(:wechat_user).order(id: :desc).page(params[:page])
    end

    private
    def set_scene
      @scene = current_user.invite_scene!(current_wechat_app, organ_id: current_organ.id)
    end

  end
end
