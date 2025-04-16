module Wechat
  module Controller::Admin
    extend ActiveSupport::Concern
    include Roled::Controller::Admin

    included do
      layout 'admin'
      skip_before_action :require_user if whether_filter(:require_user)
    end

    private
    def set_app
      @app = current_organ.apps.find_by(appid: params[:app_appid])
    end

    class_methods do
      
      private
      def local_prefixes
        [controller_path, 'wechat/admin/base']
      end
    end

  end
end
