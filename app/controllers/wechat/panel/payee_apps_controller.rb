module Wechat
  class Panel::PayeeAppsController < Panel::BaseController
    before_action :set_payee
    before_action :set_payee_app, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_payee_app, only: [:new, :create]
    before_action :set_apps, only: [:new, :create, :edit, :update]

    def index
      q_params = {}

      @payee_apps = @payee.payee_apps.default_where(q_params).order(id: :asc)
    end

    private
    def set_payee
      @payee = PartnerPayee.find params[:partner_payee_id]
    end

    def set_payee_app
      @payee_app = @payee.payee_apps.find params[:id]
    end

    def set_new_payee_app
      @payee_app = @payee.payee_apps.build(payee_app_params)
    end

    def set_apps
      @apps = @payee.organ.agencies.where.not(appid: @payee.payee_apps.pluck(:appid))
    end

    def payee_app_params
      params.fetch(:payee_app, {}).permit(
        :appid,
        :enabled
      )
    end
  end
end
