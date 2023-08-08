module Wechat
  class Panel::MenuAppsController < Panel::BaseController
    before_action :set_app
    before_action :set_menu_app, only: [:show, :edit, :update, :destroy]
    before_action :set_new_menu_app, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menu_root_apps = @app.menu_root_apps
      @menu_roots = MenuRoot.order(id: :asc)
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
    end

    private
    def set_menu_app
      @menu_app = @app.menu_apps.find(params[:id])
    end

    def set_new_menu_app
      @menu_app = @app.menu_apps.build(menu_params)
      @menu_app.menu_id = params[:menu_id] if params[:menu_id]
    end

    def set_types
      @types = Menu.options_i18n(:type)
    end

    def menu_params
      params.fetch(:menu_app, {}).permit(
        :menu_id,
        :type,
        :name,
        :value,
        :mp_appid,
        :mp_pagepath
      )
    end

  end
end
