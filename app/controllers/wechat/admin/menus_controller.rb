module Wechat
  class Admin::MenusController < Admin::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :set_types, only: [:new, :create, :edit, :update]
    before_action :set_parents, only: [:new, :edit]
    before_action :set_menu_roots, only: [:index]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.where(default_params)
      #@menus = Menu.includes(:children).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
    end

    def new
      @menu = Menu.new(type: 'Wechat::ViewMenu')
    end

    def new_parent
      @menu = Menu.new(type: 'Wechat::ParentMenu')
    end

    def edit_parent
    end

    private
    def set_menu_roots
      q_params = {}
      q_params.merge! params.permit(:name)

      @default_menus = MenuRoot.includes(:menus).where(organ_id: nil).order(position: :asc)
    end

    def set_menu
      @menu = Menu.find(params[:id])
    end

    def set_types
      @types = Menu.options_i18n(:type)
    end

    def set_parents
      q_params = {
        type: 'Wechat::ParentMenu'
      }
      q_params.merge! organ_id: [current_organ.id, nil]

      @parents = Menu.where(parent_id: nil).default_where(q_params)
    end

    def menu_params
      p = params.fetch(:menu, {}).permit(
        :parent_id,
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
