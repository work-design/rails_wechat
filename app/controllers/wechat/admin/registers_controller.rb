module Wechat
  class Admin::RegistersController < Admin::BaseController
    before_action :set_register

    def show
      if @register.new_record?
        render :new
      else
        render :show
      end
    end

    def edit_code
    end

    private
    def set_register
      @register = Register.default_where(default_params).take || Register.build(register_params)
    end

    def register_params
      p = params.fetch(:register, {}).permit(
        :id_name,
        :id_number,
        :mobile,
        :mobile_code,
        :license,
        :id_avatar,
        :id_badge,
        :bank_name,
        :bank_number
      )
      p.merge! default_form_params
    end

  end
end
