module Wechat
  class Panel::MenuDisablesController < Panel::BaseController
    before_action :set_app
    before_action :set_menu
    before_action :set_menu_disable, only: [:destroy]
    before_action :set_new_menu_disable, only: [:create]

    private
    def set_new_menu_disable
      @menu_disable = @app.menu_disables.create(menu_id: @menu.id)
    end

    def set_menu_disable
      @menu_disable = @app.menu_disables.find(params[:id])
    end

    def set_menu
      @menu = Menu.find params[:menu_id]
    end

  end
end
