module Wechat
  class Admin::ReceiversController < Admin::BaseController
    before_action :set_app
    before_action :set_payee
    before_action :set_receiver, only: [:show, :edit, :update, :destroy, :actions]

    private
    def set_app
      @app = App.find_by appid: params[:app_id]
    end

    def set_payee
      @payee = @app.payees.find params[:payee_id]
    end

    def set_receiver
      @receiver = @payee.receivers.find params[:id]
    end
  end
end
