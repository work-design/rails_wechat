module Wechat
  class Admin::RegistersController < Admin::BaseController
    before_action :set_register, only: [:show, :edit, :edit_code, :update, :destroy]
    before_action :set_new_register, only: [:new, :new_license, :create]

    def index
      @registers = current_user.registers

      if @registers.blank?
        set_new_register
        render :new
      else
        render 'index'
      end
    end

    def edit_code
    end

    private
    def set_new_register
      @register = Register.build(register_params)
    end

    def set_register
      @register = Register.default_where(default_params).find(params[:id])
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
