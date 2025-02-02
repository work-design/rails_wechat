module Wechat
  class Admin::PayeeAppsController < Panel::PayeeAppsController

    def index
      q_params = {}

      @payee_apps = @payee.payee_apps.default_where(q_params).order(id: :asc)
    end

    private
    def set_payee
      @payee = Payee.default_where(default_params).find params[:payee_id]
    end

    def set_apps
      @apps = App.default_where(default_params)
    end
  end
end
