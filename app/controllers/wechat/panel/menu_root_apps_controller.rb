module Wechat
  class Panel::MenuRootAppsController < Panel::BaseController
    before_action :set_app
    before_action :set_new_menu_root_app, only: [:new, :create]

    private
    def set_new_menu_root_app
      @menu_root_app = @app.menu_root_apps.build(menu_root_app_params)
      @menu_root_app.menu_root_id = params[:menu_root_id] if params[:menu_root_id]
    end

    def menu_root_app_params
      params.fetch(:menu_root_app, {}).permit(
        :name,
        :menu_root_id
      )
    end

  end
end
