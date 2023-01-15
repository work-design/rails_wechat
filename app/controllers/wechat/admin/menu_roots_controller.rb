module Wechat
  class Admin::MenuRootsController < Admin::BaseController


    private
    def set_menu_root
      @menu_root = MenuRoot.where(position: params[:position]).find_or_create_by(organ_id: current_organ.id)
    end

    def menu_root_params
      r = params.fetch(:menu_root, {}).permit(
        :name,
        :position
      )
      r.merge! default_form_params
    end

  end
end
