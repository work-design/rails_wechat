module Wechat
  class Panel::MenusController < Panel::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :set_menu_root, only: [:new, :create]
    before_action :set_new_menu, only: [:new, :create]
    before_action :set_types, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.includes(:menus).order(position: :asc)
    end

    private
    def set_menu
      @menu = Menu.find(params[:id])
    end

    def set_menu_root
      @menu_root = MenuRoot.find params[:menu_root_id]
    end

    def set_new_menu
      @menu = @menu_root.menus.build(menu_params)
    end

    def set_types
      @types = Menu.options_i18n(:type)
    end

    def menu_params
      params.fetch(:menu, {}).permit(
        :type,
        :name,
        :value,
        :mp_appid,
        :mp_pagepath,
        :position
      )
    end

  end
end
