class Wechat::Admin::WechatMenusController < Wechat::Admin::BaseController
  before_action :set_wechat_config
  before_action :set_wechat_menu, only: [:show, :edit, :edit_parent, :update, :destroy]
  before_action :prepare_form, only: [:new, :create, :edit, :update]
  
  def index
    q_params = {}
    q_params.merge! wechat_config_id: [params[:wechat_config_id], nil].uniq
    
    @wechat_menus = WechatMenu.where(q_params).order(parent_id: :desc, id: :asc).page(params[:page])
  end

  def new
    @wechat_menu = WechatMenu.new
  end

  def create
    @wechat_menu = WechatMenu.new(wechat_menu_params)

    respond_to do |format|
      if @wechat_menu.save
        format.html.phone
        format.html { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.js { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.json { render :show }
      else
        format.html.phone { render :new }
        format.html { render :new }
        format.js { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.json { render :show }
      end
    end
  end
  
  def sync
    r = Wechat.api(@wechat_config.id).menu_create @wechat_config.menu
    redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id), notice: r.to_s
  end

  def show
  end

  def edit
  end

  def edit_parent
  end

  def update
    @wechat_menu.assign_attributes(wechat_menu_params)

    respond_to do |format|
      if @wechat_menu.save
        format.html.phone
        format.html { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.js { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.json { render :show }
      else
        format.html.phone { render :edit }
        format.html { render :edit }
        format.js { redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id) }
        format.json { render :show }
      end
    end
  end

  def destroy
    @wechat_menu.destroy
    redirect_to admin_wechat_menus_url(wechat_config_id: @wechat_menu.wechat_config_id)
  end

  private
  def set_wechat_config
    @wechat_config = WechatConfig.where(default_params).find_by id: params[:wechat_config_id]
  end
  
  def set_wechat_menu
    @wechat_menu = WechatMenu.find(params[:id])
  end
  
  def prepare_form
    @types = WechatMenu.options_i18n(:type)
    @types.reject! { |_, v| v == :ParentMenu }
    
    @parents = WechatMenu.where(type: 'ParentMenu', parent_id: nil, wechat_config_id: params[:wechat_config_id])
  end

  def wechat_menu_params
    params.fetch(:wechat_menu, {}).permit(
      :wechat_config_id,
      :parent_id,
      :type,
      :name,
      :value,
      :appid,
      :pagepath
    )
  end

end
