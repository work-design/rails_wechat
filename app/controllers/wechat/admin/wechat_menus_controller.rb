class Wechat::Admin::WechatMenusController < Wechat::Admin::BaseController
  before_action :set_wechat_app
  before_action :set_wechat_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]

  def default
    q_params = {}
    q_params.merge! wechat_app_id: nil

    @wechat_menus = WechatMenu.where(q_params).order(parent_id: :desc, id: :asc).page(params[:page])

    render 'index'
  end

  def index
    q_params = {}
    q_params.merge! wechat_app_id: [params[:wechat_app_id], nil].uniq

    @wechat_menus = WechatMenu.where(q_params).order(parent_id: :desc, id: :asc).page(params[:page])
  end

  def new
    @wechat_menu = WechatMenu.new(wechat_app_id: params[:wechat_app_id])
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
    @wechat_app = WechatApp.default_where(default_params).find_by id: params[:wechat_app_id]
  end

  def set_wechat_menu
    @wechat_menu = WechatMenu.find(params[:id])
  end

  def prepare_form
    @types = WechatMenu.options_i18n(:type)
    @types.reject! { |_, v| v == :ParentMenu }

    @parents = WechatMenu.where(type: 'ParentMenu', parent_id: nil, wechat_app_id: params[:wechat_app_id])
  end

  def wechat_menu_params
    params.fetch(:wechat_menu, {}).permit(
      :wechat_app_id,
      :parent_id,
      :type,
      :name,
      :value,
      :appid,
      :pagepath
    )
  end

end
