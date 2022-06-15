module Wechat
  class Into::AppMenusController < Into::BaseController
    before_action :set_app
    before_action :set_scene
    before_action :set_app_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :set_default_menus, only: [:index]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @menus = Menu.roots.where(q_params).order(parent_id: :desc, position: :asc)

      @scene_menu_ids = @scene.app_menus.pluck(:menu_id)
    end

    def new
      @menu = @app.menus.build(type: 'Wechat::ViewMenu')
      @menu.scene_menus.build

      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: params[:appid])
    end

    def new_parent
      @menu = Menu.new(appid: params[:appid])
    end

    def create
      @app_menu = @scene.app_menus.build(menu_params)

      unless @app_menu.save
        render :new, locals: { model: @app_menu }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
    end

    def edit
      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: @menu.appid)
    end

    def edit_parent
    end

    private
    def set_scene
      @scene = Scene.find params[:scene_id]
    end

    def set_default_menus
      q_params = {}
      q_params.merge! params.permit(:name)

      @default_menus = Menu.roots.where(organ_id: nil).where(q_params).order(parent_id: :desc, position: :asc)
    end

    def set_app_menu
      @app_menu = @app.app_menus.find(params[:id])
    end

    def menu_params
      params.fetch(:app_menu, {}).permit(
        :menu_id,
        :scene_id
      )
    end

  end
end
