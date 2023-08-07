module Wechat
  class Admin::MenuRootsController < Admin::BaseController
    before_action :set_menu_root, only: [:new, :create]

    def index
      @menu_roots = MenuRoot.where(organ_id: nil)
    end

    private
    def set_menu_root
      @menu_root = MenuRoot.where(position: params[:position]).find_or_initialize_by(organ_id: current_organ.id)
      @menu_root.assign_attributes(menu_root_params)
    end

    def menu_root_params
      params.fetch(:menu_root, {}).permit(
        :name
      )
    end

  end
end
