module Wechat
  class Panel::MenusController < Panel::BaseController
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! params.permit(:name)

      @menus = Menu.includes(:children).where(appid: nil).roots.default_where(q_params).order(parent_id: :desc, position: :asc).page(params[:page])
    end

    def new
      @menu = Menu.new(type: 'Wechat::ViewMenu')
      @parents = Menu.roots.where(appid: nil).where(type: 'Wechat::ParentMenu')
    end

    def new_parent
      @menu = Menu.new
    end

    def create
      @menu = Menu.new(menu_params)

      unless @menu.save
        render :new, locals: { model: @menu }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: @menu.appid)
    end

    def edit_parent
    end

    def update
      @menu.assign_attributes(menu_params)

      unless @menu.save
        render :edit, locals: { model: @menu }, status: :unprocessable_entity
      end
    end

    def destroy
      @menu.destroy
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
