module Wechat
  class CorpsController < BaseController
    skip_before_action :verify_authenticity_token, raise: false if whether_filter(:verify_authenticity_token)
    before_action :set_corp, only: [:login]

    def login
      @corp_user = @corp.generate_corp_user(params[:code])
      @corp_user.save

      xxx(@corp_user)
    end

    private
    def set_corp
      @corp = Corp.find(params[:id])
    end

  end
end
