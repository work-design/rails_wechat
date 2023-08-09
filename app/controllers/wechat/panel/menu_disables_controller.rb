module Wechat
  class Panel::MenuDisablesController < Panel::BaseController
    before_action :set_app
    before_action :set_menu_disable, only: [:show, :edit, :update, :destroy]

    private
    def set_menu_disable
      @menu_disable = MenuDisable.find(params[:id])
    end

    def set_menu
      @menu = @menu_root.menus.build(appid: params[:appid])
    end

  end
end
