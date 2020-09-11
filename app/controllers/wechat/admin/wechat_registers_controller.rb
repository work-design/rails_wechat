class Wechat::Admin::WechatRegistersController < Wechat::Admin::BaseController
  before_action :set_wechat_register, only: [
    :show, :code, :qrcode,
    :edit, :edit_app, :edit_bind, :update_bind, :edit_assign, :update_assign, :edit_qrcode,
    :update, :destroy
  ]

  def index
    q_params = {}
    q_params.merge! params.permit(:id_name, :id_number)

    @wechat_registers = WechatRegister.default_where(q_params).order(id: :desc).page(params[:page])
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

  def code
    @wechat_register.notify_mobile_code
  end

  def qrcode
  end

  def edit
  end

  def edit_app
  end

  def edit_bind
  end

  def update_bind
    @wechat_register.assign_attributes wechat_register_params
    if @wechat_register.save
      @wechat_register.notify_qrcode
    end
    render 'update'
  end

  def edit_qrcode
  end

  def edit_assign
    q_params = {
      organ_id: current_organ&.id
    }
    @members = @wechat_register.members.default_where(q_params)
    @task_templates = @wechat_register.task_templates.default_where(member_id: params[:member_id])
  end

  def update_assign
    @wechat_register.to_task!(params[:member_id], params[:task_template_id])
    render 'update'
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
      :id_number,
      :mobile,
      :bind_qrcode,
      :appid,
      :password,
      :qrcode
    )
  end

end
