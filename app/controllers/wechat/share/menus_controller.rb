module Wechat
  class Share::MenusController < Share::BaseController
    before_action :set_wechat_app
    before_action :set_scene
    before_action :set_wechat_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
    before_action :prepare_form, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! appid: [@app.appid, nil].uniq

      @wechat_menus = Menu.where(q_params).order(parent_id: :desc, position: :asc).page(params[:page])

      @scene_wechat_menu_ids = @scene.scene_menus.pluck(:wechat_menu_id)
    end

    def new
      @wechat_menu = @app.wechat_menus.build(type: 'Wechat::ViewMenu')
      @wechat_menu.scene_menus.build

      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: params[:appid])
    end

    def new_parent
      @wechat_menu = Menu.new(appid: params[:appid])
    end

    def create
      @wechat_menu = @app.wechat_menus.new(wechat_menu_params)

      unless @wechat_menu.save
        render :new, locals: { model: @wechat_menu }, status: :unprocessable_entity
      end
    end

    def sync
      r = @app.sync_menu
      render 'sync', locals: { notice: r.to_s }
    end

    def show
    end

    def edit
      @parents = Menu.where(type: 'Wechat::ParentMenu', parent_id: nil, appid: @wechat_menu.appid)
    end

    def edit_parent
    end

    def update
      @wechat_menu.assign_attributes(wechat_menu_params)

      unless @wechat_menu.save
        render :edit, locals: { model: @wechat_menu }, status: :unprocessable_entity
      end
    end

    def destroy
      @wechat_menu.destroy
    end

    private
    def set_scene
      @scene = Scene.find params[:scene_id]
    end

    def set_wechat_menu
      @wechat_menu = Menu.find(params[:id])
    end

    def prepare_form
      @types = Menu.options_i18n(:type)
      @types.reject! { |_, v| v == :ParentMenu }
    end

    def wechat_menu_params
      params.fetch(:wechat_menu, {}).permit(
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
