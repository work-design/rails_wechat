module Wechat
  class My::WechatRegistersController < My::BaseController
    before_action :set_wechat_register, only: [:show, :edit, :edit_code, :update, :destroy]

    def index
      @wechat_registers = current_user.wechat_registers

      if @wechat_registers.blank?
        new_wechat_register
        render :new
      else
        render 'index'
      end
    end

    def new
      new_wechat_register
    end

    def create
      new_wechat_register

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

    def edit_code
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
    def new_wechat_register
      @wechat_register = current_user.wechat_registers.build(wechat_register_params)
      @wechat_register.mobile ||= current_account.identity if current_account.is_a?(Auth::MobileAccount)
    end

    def set_wechat_register
      @wechat_register = WechatRegister.find(params[:id])
    end

    def wechat_register_params
      p = params.fetch(:wechat_register, {}).permit(
        :id_name,
        :id_number,
        :mobile,
        :mobile_code
      )
      p.merge! default_form_params
    end

  end
end
