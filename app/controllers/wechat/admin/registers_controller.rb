module Wechat
  class Admin::RegistersController < Admin::BaseController
    before_action :set_register, only: [
      :show, :code, :qrcode,
      :edit, :edit_app, :edit_bind, :update_bind, :edit_assign, :update_assign, :edit_qrcode,
      :update, :destroy
    ]

    def index
      q_params = {}
      q_params.merge! params.permit(:id_name, :id_number)

      @registers = Register.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @register = Register.new
    end

    def create
      @register = Register.new(register_params)

      unless @register.save
        render :new, locals: { model: @register }, status: :unprocessable_entity
      end
    end
    def code
      @register.notify_mobile_code
    end

    def qrcode
    end

    def edit_app
    end

    def edit_bind
    end

    def update_bind
      @register.assign_attributes register_params
      if @register.save
        @register.notify_qrcode
      end
      render 'update'
    end

    def edit_qrcode
    end

    def edit_assign
      q_params = {
        organ_id: current_organ&.id
      }
      @members = @register.members.default_where(q_params)
      @task_templates = @register.task_templates.default_where(member_id: params[:member_id])
    end

    def update_assign
      @register.to_task!(params[:member_id], params[:task_template_id])
      render 'update'
    end

    private
    def set_register
      @register = Register.find(params[:id])
    end

    def register_params
      params.fetch(:register, {}).permit(
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
end
