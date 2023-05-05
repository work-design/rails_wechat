module Wechat
  class WorkAppsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_work_app, only: [:login]

    def login
      @corp_user = @work_app.generate_corp_user(params[:code])
      @corp_user.save

      login_by_corp_user(@corp_user)
    end

    private
    def set_work_app
      @work_app = WorkApp.find(params[:id])
    end

  end
end
