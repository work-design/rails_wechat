module Wechat
  class Admin::AccountsController < Admin::BaseController
    before_action :set_account, only: [:qrcode]

    def qrcode
      @account.qrcode
    end

    private
    def set_account
      @account = Account.find(params[:id])
    end

    def account_params
      params.fetch(:account, {}).permit(
        :user_id,
        :type,
        :identity,
        :confirmed,
        :primary
      )
    end

  end
end
