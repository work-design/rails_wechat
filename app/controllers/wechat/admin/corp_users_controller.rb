module Wechat
  class Admin::CorpUsersController < Admin::BaseController
    before_action :set_app
    before_action :set_corp_user, only: [:show, :edit, :update, :destroy]

    def index
      @corp_users = @app.corp_users.page(params[:page])
    end

    private
    def set_corp_user
      @corp_user = @app.corp_users.find params[:id]
    end

  end
end
