module Wechat
  class Admin::MenuAppsController < Admin::BaseController
    before_action :set_app
    before_action :set_menu_app, only: [:show, :edit, :update, :destroy]
    before_action :set_new_menu_app, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.includes(:menus).where(organ_id: [nil, current_organ.id]).order(position: :asc)
      @menus = @menu_roots.group_by(&:position).transform_values! do |x|
        x.find(&->(i){ i.organ_id == current_organ.id }) || x.find(&->(i){ i.organ_id.nil? })
      end.values
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
    end

    def edit
      @parents = @app.menus.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: @menu.appid)
    end

    private
    def set_menu_app
      @menu_app = @app.menu_apps.find(params[:id])
    end

    def set_new_menu_app
      @menu_app = @app.menu_apps.build(menu_params)
    end

    def set_types
      @types = Menu.options_i18n(:type)
    end

    def menu_params
      params.fetch(:menu_app, {}).permit(
        :menu_id
      )
    end

  end
end
