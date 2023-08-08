module Wechat
  class Admin::MenuRootAppsController < Admin::BaseController
    before_action :set_app
    before_action :set_menu_root, only: [:new, :create]

    def index
      @menu_roots = MenuRoot.where(organ_id: nil)
    end

    private
    def set_menu_root
      @menu_root = MenuRoot.find(params[:menu_root_id])
    end

    def set_new_menu_root_app
      @menu_root_app = @app.menu_root_apps.build(menu_root_app_params)
    end

    def menu_root_app_params
      params.fetch(:menu_root_app, {}).permit(
        :name
      )
    end

  end
end
