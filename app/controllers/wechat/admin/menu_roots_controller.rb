module Wechat
  class Admin::MenuRootsController < Admin::BaseController


    private
    def menu_root_params
      r = params.fetch(:menu_root, {}).permit(
        :name,
        :position
      )
      r.merge! default_form_params
    end

  end
end
