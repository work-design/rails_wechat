module Wechat
  class Admin::AppPayeesController < Admin::BaseController
    before_action :set_app
    before_action :set_app_payee, only: [:show, :edit, :update, :destroy, :actions, :edit_cert, :update_cert]
    before_action :set_new_app_payee, only: [:new, :create]

    def index
      q_params = {}

      @app_payees = @app.app_payees.default_where(q_params)
    end

    private
    def set_app_payee
      @app_payee = @app.app_payees.find params[:id]
    end

    def set_new_app_payee
      @payee = @app.payees.build(payee_params)
    end

    def payee_params
      p = params.fetch(:app_payee, {}).permit(
        :mch_id,
        :domain
      )
      p.merge! default_form_params
    end
  end
end
