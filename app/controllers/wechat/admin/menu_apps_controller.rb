module Wechat
  class Admin::MenuAppsController < Admin::BaseController
    before_action :set_app
    before_action :set_app_menu, only: [:show, :edit, :update, :destroy]
    before_action :set_default_menus, only: [:index]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @menus = Menu.includes(:children).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
    end

    def new
      @menu = @app.menus.build(type: 'Wechat::ViewMenu')
      @parents = @app.menus.where(type: 'Wechat::ParentMenu', parent_id: nil)
    end

    def new_parent
      @menu = @app.menus.build
    end

    def create
      @app_menu = @app.app_menus.build(menu_params)

      unless @app_menu.save
        render :new, locals: { model: @menu }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
    end

    def edit
      @parents = @app.menus.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: @menu.appid)
    end

    def edit_parent
    end

    private
    def set_app_menu
      @app_menu = @app.app_menus.find(params[:id])
    end

    def set_default_menus
      q_params = {}
      q_params.merge! params.permit(:name)

      @default_menus = Menu.includes(:children).where(organ_id: nil).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
    end

    def set_types
      @types = Menu.options_i18n(:type)
      @types.reject! { |_, v| v == :ParentMenu }
    end

    def menu_params
      params.fetch(:app_menu, {}).permit(
        :menu_id
      )
    end

  end
end
