module Wechat
  class Admin::CorpUsersController < Admin::BaseController
    before_action :set_app

    def index
      @corp_users = @app.corp_users.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find_by corp_id: params[:provider_id]
    end

    def set_suite
      @app = WorkApp.find_by appid: params[:appid]
    end

  end
end
