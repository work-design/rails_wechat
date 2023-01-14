module Wechat
  class Admin::MenuOrgansController < Admin::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :set_types, only: [:new, :create, :edit, :update]
    before_action :set_parents, only: [:new, :edit]
    before_action :set_default_menus, only: [:index]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:name)

      @menus = Menu.includes(:children).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
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
    def set_default_menus
      q_params = {}
      q_params.merge! params.permit(:name)

      @default_menus = Menu.includes(:children).where(organ_id: nil).roots.default_where(q_params).order(parent_id: :desc, position: :asc)
    end

    def set_menu
      @menu = Menu.find(params[:id])
    end

    def set_types
      @types = Menu.options_i18n(:type)
      @types.reject! { |_, v| v == :'Wechat::ParentMenu' }
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
