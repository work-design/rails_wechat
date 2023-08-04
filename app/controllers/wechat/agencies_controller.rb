module Wechat
  class AgenciesController < BaseController
    before_action :set_agency, only: [:login, :callback]

    def login
      @oauth_user = @agency.generate_wechat_user(params[:code])
      @oauth_user.save

      login_by_oauth_user(@oauth_user)
    end

    def callback
      @agency.ticket = params[:ticket]
      @agency.save
    end

    private
    def set_agency
      @agency = Agency.find params[:id]
    end

  end
end
