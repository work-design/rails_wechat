class Wechat::My::WechatRegistersController < Wechat::My::BaseController
  before_action :set_wechat_register, only: [:show, :edit, :update, :destroy]

  def index
    @wechat_registers = WechatRegister.page(params[:page])
  end

  def new
    @wechat_register = current_member.wechat_registers.build
  end

  def create
    @wechat_register = current_member.wechat_registers.build(wechat_register_params)

    if @wechat_register.save
      render 'create', locals: { return_to: my_wechat_registers_url }
    else
      render :new, locals: { model: @wechat_register }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_register.assign_attributes(wechat_register_params)

    if @wechat_register.save
      render 'update', locals: { return_to: my_wechat_registers_url }
    else
      render :edit, locals: { model: @wechat_register }, status: :unprocessable_entity
    end
  end

  def destroy
    @wechat_register.destroy
  end

  private
  def set_wechat_register
    @wechat_register = WechatRegister.find(params[:id])
  end

  def wechat_register_params
    params.fetch(:wechat_register, {}).permit(
      :id_name,
      :id_number
    )
  end

end
