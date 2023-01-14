module Wechat
  class Panel::MenusController < Panel::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menu_roots = MenuRoot.includes(:menus).where(organ_id: nil)
      #@menus = Menu.where(organ_id: nil).default_where(q_params).order(m_id: :desc, position: :asc).page(params[:page])
    end

    def new
      @menu = Menu.new(type: 'Wechat::ViewMenu')
      @parents = Menu.roots.where(appid: nil).where(type: 'Wechat::ParentMenu')
    end

    private
    def set_menu
      @menu = Menu.find(params[:id])
    end

    def prepare_form
      @types = Menu.options_i18n(:type)
      @types.reject! { |_, v| v == :ParentMenu }
    end

    def menu_params
      params.fetch(:menu, {}).permit(
        :parent_id,
        :type,
        :name,
        :value,
        :mp_appid,
        :mp_pagepath,
        :position
      )
    end

  end
end
