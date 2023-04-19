module Wechat
  class Admin::PayeeAppsController < Admin::BaseController
    before_action :set_app
    before_action :set_payee_app, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_payee_app, only: [:new, :create]
    before_action :set_payees, only: [:new, :create, :edit, :update]

    def index
      q_params = {}

      @payee_apps = @app.payee_apps.default_where(q_params)
    end

    private
    def set_payee_app
      @payee_app = @app.payee_apps.find params[:id]
    end

    def set_new_payee_app
      @payee_app = @app.payee_apps.build(payee_app_params)
    end

    def set_payees
      @payees = Payee.all.limit(5)
    end

    def payee_app_params
      params.fetch(:payee_app, {}).permit(
        :mch_id,
        :enabled,
        :domain
      )
    end
  end
end
