module Wechat
  module Controller::Admin
    extend ActiveSupport::Concern
    include Roled::Controller::Admin

    included do
      layout -> { turbo_frame_body? ? 'frame_body' : 'admin' }
      skip_before_action :require_user if whether_filter(:require_user)
    end

    private
    def set_app
      @app = current_organ.apps.find_by(appid: params[:app_appid])
    end

  end
end
