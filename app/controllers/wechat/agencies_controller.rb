module Wechat
  class AgenciesController < BaseController
    before_action :set_agency, only: [:login]

    def login
      @oauth_user = @agency.generate_wechat_user(params[:code])
      if @oauth_user.account.nil? && current_account
        @oauth_user.account = current_account
      end
      @oauth_user.save

      xxx(@oauth_user)
    end

    private
    def set_agency
      @agency = Agency.find params[:id]
    end

  end
end
