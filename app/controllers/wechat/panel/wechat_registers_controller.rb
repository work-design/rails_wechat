class Wechat::Panel::WechatRegistersController < Wechat::Panel::BaseController
  before_action :set_wechat_register, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! params.permit(:id_name, :id_number)

    @wechat_registers = WechatRegister.default_where(q_params).page(params[:page])
  end

  def new
    @wechat_register = WechatRegister.new
  end

  def create
    @wechat_register = WechatRegister.new(wechat_register_params)

    unless @wechat_register.save
      render :new, locals: { model: @wechat_register }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @wechat_register.assign_attributes(wechat_register_params)

    unless @wechat_register.save
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
