module Wechat
  class AgenciesController < BaseController
    before_action :set_agency, only: [:login, :callback]
    skip_after_action :set_auth_token, only: [:login] if whether_filter :set_auth_token

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
      @agency = Agency.find_by appid: params[:appid]
    end

  end
end
