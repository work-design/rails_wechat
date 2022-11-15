module Wechat
  class Admin::AppPayeesController < Admin::BaseController
    before_action :set_app
    before_action :set_app_payee, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_app_payee, only: [:new, :create]
    before_action :set_payees, only: [:new, :create, :edit, :update]

    def index
      q_params = {}

      @app_payees = @app.app_payees.default_where(q_params)
    end

    private
    def set_app_payee
      @app_payee = @app.app_payees.find params[:id]
    end

    def set_new_app_payee
      @app_payee = @app.app_payees.build(app_payee_params)
    end

    def set_payees
      @payees = Payee.all.limit(5)
    end

    def app_payee_params
      params.fetch(:app_payee, {}).permit(
        :payee_id,
        :domain
      )
    end
  end
end
