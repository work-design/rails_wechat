module Wechat
  class Admin::MenusController < Admin::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :set_types, only: [:new, :create, :edit, :update]
    before_action :set_menu_root, only: [:new, :create]
    before_action :set_new_menu, only: [:new, :create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.includes(:menus).where(organ_id: [nil, current_organ.id]).order(position: :asc)
      @menus = @menu_roots.group_by(&:position).transform_values! do |x|
        x.find(&->(i){ i.organ_id == current_organ.id }) || x.find(&->(i){ i.organ_id.nil? })
      end.values
      #@menus = Menu.includes(:children).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
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
      p = params.fetch(:menu, {}).permit(
        :root_position,
        :type,
        :name,
        :value,
        :mp_appid,
        :mp_pagepath,
        :position
      )
      p.merge! default_form_params
    end

  end
end
