module Wechat
  class AgenciesController < BaseController
    before_action :set_agency, only: [:login]

    def login
      @oauth_user = @agency.generate_wechat_user(params[:code])
      @oauth_user.user || @oauth_user.build_user
      @oauth_user.save

      xxx(@oauth_user)
    end

    private
    def set_agency
      @agency = Agency.find params[:id]
    end

  end
end
