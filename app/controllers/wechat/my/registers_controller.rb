module Wechat
  class My::RegistersController < My::BaseController
    before_action :set_register, only: [:show, :edit, :edit_code, :update, :destroy]
    before_action :set_new_register, only: [:new, :create]

    def index
      @registers = current_user.registers

      if @registers.blank?
        new_register
        render :new
      else
        render 'index'
      end
    end

    def edit_code
    end

    private
    def set_new_register
      @register = current_user.registers.build(register_params)
      @register.mobile ||= current_account.identity if current_account.is_a?(::Auth::MobileAccount)
    end

    def set_register
      @register = Register.find(params[:id])
    end

    def register_params
      p = params.fetch(:register, {}).permit(
        :id_name,
        :id_number,
        :mobile,
        :mobile_code
      )
      p.merge! default_form_params
    end

  end
end
