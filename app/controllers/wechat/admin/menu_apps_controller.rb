module Wechat
  class Admin::MenuAppsController < Admin::BaseController
    before_action :set_app
    before_action :set_app_menu, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.includes(:menus).where(organ_id: [nil, current_organ.id]).order(position: :asc)
      @menus = @menu_roots.group_by(&:position).transform_values! do |x|
        x.find(&->(i){ i.organ_id == current_organ.id }) || x.find(&->(i){ i.organ_id.nil? })
      end.values
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

    def set_types
      @types = Menu.options_i18n(:type)
    end

    def menu_params
      params.fetch(:app_menu, {}).permit(
        :menu_id
      )
    end

  end
end
