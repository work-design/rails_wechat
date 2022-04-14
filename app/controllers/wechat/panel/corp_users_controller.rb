module Wechat
  class Panel::CorpUsersController < Panel::BaseController
    before_action :set_provider
    before_action :set_suite
    before_action :set_corp

    def index
      @corp_users = @corp.corp_users.page(params[:page])
    end

    private
    def set_provider
      @provider = Provider.find_by corp_id: params[:provider_id]
    end

    def set_suite
      @suite = Suite.find_by suite_id: params[:suite_id]
    end

    def set_corp
      @corp = Corp.find_by corp_id: params[:corp_id], suite_id: params[:suite_id]
    end

  end
end
