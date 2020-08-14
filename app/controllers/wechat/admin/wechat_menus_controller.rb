class Wechat::Admin::WechatMenusController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]

  def default
    q_params = {}
    @wechat_menus = WechatMenu.where(appid: nil).order(parent_id: :desc, position: :asc).page(params[:page])

    render 'index'
  end

  def index
    q_params = {}
    q_params.merge! appid: [params[:appid], nil].uniq

    @wechat_menus = WechatMenu.where(q_params).order(parent_id: :desc, position: :asc).page(params[:page])
  end

  def new
    @wechat_menu = WechatMenu.new(appid: params[:appid], type: 'ViewMenu')
    @parents = WechatMenu.where(type: 'ParentMenu', parent_id: nil, appid: params[:appid])
  end

  def new_parent
    @wechat_menu = WechatMenu.new(appid: params[:appid])
  end

  def create
    @wechat_menu = WechatMenu.new(wechat_menu_params)

    unless @wechat_menu.save
      render :new, locals: { model: @wechat_menu }, status: :unprocessable_entity
    end
  end

  def sync
    r = @wechat_app.sync_menu
    redirect_to admin_wechat_menus_url(wechat_app_id: @wechat_app.id), notice: r.to_s
  end

  def show
  end

  def edit
    @parents = WechatMenu.where(type: 'ParentMenu', parent_id: nil, appid: @wechat_menu.appid)
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
  def set_wechat_app
    @wechat_app = WechatApp.default_where(default_params).find_by appid: params[:appid]
  end

  def set_wechat_menu
    @wechat_menu = WechatMenu.find(params[:id])
  end

  def prepare_form
    @types = WechatMenu.options_i18n(:type)
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
      :position
    )
  end

end
