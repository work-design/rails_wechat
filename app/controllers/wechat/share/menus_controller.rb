module Wechat
  class Share::MenusController < Share::BaseController
    before_action :set_app
    before_action :set_scene
    before_action :set_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! appid: [@app.appid, nil].uniq

      @menus = Menu.where(q_params).order(parent_id: :desc, position: :asc).page(params[:page])

      @scene_menu_ids = @scene.scene_menus.pluck(:menu_id)
    end

    def new
      @menu = @app.menus.build(type: 'Wechat::ViewMenu')
      @menu.scene_menus.build

      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: params[:appid])
    end

    def new_parent
      @menu = Menu.new(appid: params[:appid])
    end

    def create
      @menu = @app.menus.new(menu_params)

      unless @menu.save
        render :new, locals: { model: @menu }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
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
    def set_scene
      @scene = Scene.find params[:scene_id]
    end

    def set_menu
      @menu = Menu.find(params[:id])
    end

    def prepare_form
      @types = Menu.options_i18n(:type)
      @types.reject! { |_, v| v == :ParentMenu }
    end

    def menu_params
      params.fetch(:menu, {}).permit(
        :appid,
        :parent_id,
        :type,
        :name,
        :value,
        :mp_appid,
        :mp_pagepath,
        :position,
        scene_menus_attributes: {}
      )
    end

  end
end
